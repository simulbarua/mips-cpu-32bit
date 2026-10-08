#!/usr/bin/env python3
"""Compile isolated designs and check factorial against Python's reference."""
import argparse
import json
import math
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]

def r(rs, rt, rd, funct, shamt=0):
    return (rs<<21) | (rt<<16) | (rd<<11) | (shamt<<6) | funct

def i(op, rs, rt, imm):
    return (op<<26) | (rs<<21) | (rt<<16) | (imm&0xffff)

def directed(build):
    cases = {
        'newest-forward': ([i(8,0,8,1),i(8,8,8,1),r(8,0,16,32)],2),
        'branch-full-width': ([i(8,0,8,2),i(8,0,9,4),i(4,8,9,2),i(8,0,16,7),0x08000006,i(8,0,16,99)],7),
        'taken-branch-flush': ([i(8,0,16,7),i(8,0,8,2),i(4,8,8,1),i(8,0,16,99)],7),
        'load-use': ([i(8,0,8,42),i(43,0,8,0),i(35,0,9,0),r(9,0,16,32)],42),
        'jr-after-load': ([i(8,0,8,24),i(43,0,8,0),i(35,0,9,0),r(9,0,0,8),i(8,0,16,99),0x08000018,i(8,0,16,7)],7),
        'jal-link-forward': ([0x0c000002,i(8,0,16,99),r(31,0,16,32)],4),
        'hi-product': ([i(8,0,8,-1),i(8,0,9,2),r(8,9,0,25),r(0,0,16,16)],1),
        'signed-slt': ([i(8,0,8,-1),i(8,0,9,1),r(8,9,16,42)],1),
        'shamt-only-change': ([i(8,0,8,1),r(0,8,16,0,1),r(0,8,16,0,2)],4),
    }
    for name,(program,expected) in cases.items():
        # Allow write-back to complete before observing the stop address.
        program += [0]*5+[0x08000018]
        program += [0]*(64-len(program))
        (build/'memfile.mem').write_text('\n'.join(f'{w:08X}' for w in program)+'\n')
        result=subprocess.run(['vvp','sim.vvp',f'+EXPECTED={expected}'],cwd=build,capture_output=True,text=True,timeout=15)
        (build/f'{name}.log').write_text(result.stdout+result.stderr)
        if result.returncode or 'PASS ' not in result.stdout:
            raise RuntimeError(f'{build.name} {name}: {result.stdout[-1500:]}')
        print(build.name,'PASS',name)

def run(variant):
    source = ROOT / 'designs' / variant
    build = ROOT / 'build' / variant
    build.mkdir(parents=True, exist_ok=True)
    top = 'tb_soc' if variant == 'soc' else 'tb_cpu'
    files = sorted(source.rglob('*.v'))
    result = subprocess.run(['iverilog', '-g2012', '-Wall', '-s', top, '-o', str(build/'sim.vvp'), *map(str, files)], capture_output=True, text=True)
    (build/'compile.log').write_text(result.stdout + result.stderr)
    if result.returncode:
        raise RuntimeError(result.stderr)
    records = []
    for n in range(16 if variant == 'soc' else 13):
        expected = 0 if n > 12 else math.factorial(n)
        if variant == 'soc':
            shutil.copyfile(source/'memfile.mem',build/'memfile.mem')
        else:
            words = (source/'memfile.mem').read_text().splitlines()
            words[1] = f'{0x20040000|n:08X}'
            # End in a self-loop after the two shift instructions.
            words += ['08000018']
            words += ['00000000'] * (64-len(words))
            (build/'memfile.mem').write_text('\n'.join(words)+'\n')
        result = subprocess.run(['vvp','sim.vvp',f'+N={n}',f'+EXPECTED={expected}'], cwd=build, capture_output=True, text=True, timeout=15)
        (build/f'n{n}.log').write_text(result.stdout+result.stderr)
        if result.returncode or 'PASS ' not in result.stdout:
            raise RuntimeError(f'{variant} n={n}: {result.stdout[-2000:]} {result.stderr}')
        line = next(s for s in result.stdout.splitlines() if s.startswith('PASS '))
        print(variant, line)
        records.append({'n':n,'expected':expected,'result':'pass','cycles':int(line.split('cycles=')[1])})
    (build/'results.json').write_text(json.dumps(records, indent=2)+'\n')
    if variant != 'soc':
        directed(build)
    return records

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('variant',choices=['all','single-cycle','pipeline','soc'],default='all',nargs='?')
    args = parser.parse_args()
    for variant in ['single-cycle','pipeline','soc'] if args.variant == 'all' else [args.variant]:
        run(variant)
