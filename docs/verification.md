# Verification

Run `python3 scripts/test.py all` with Python 3 and Icarus Verilog. There are no Python package dependencies. Compilation and simulation failures return a nonzero exit code. Each simulation has a bounded clock-cycle loop and a process timeout.

## Current checks

| Target | Checks | Passed locally |
|---|---|---|
| Single-cycle CPU | Factorial n=0–12; nine focused programs | 22/22 |
| Pipeline CPU | Factorial n=0–12; nine focused programs | 22/22 |
| SoC | Factorial n=0–12; invalid n=13–15 | 16/16 |
| Total | Output assertions | 60/60 |

Focused CPU programs exercise: consecutive writes/forwarding priority, full-width branch comparison, taken-branch flushing, immediate load-use, `jr` after a load, immediate use of a `jal` link, `mfhi` with a nonzero upper product, negative signed `slt`, and changing only the shift amount while ALU operands remain constant.

The reference factorial is calculated independently with Python `math.factorial`. CPU results are observed through register 16 (`$s0`). SoC results and error flags are observed through GPIO outputs. Case-specific logs and per-input cycle/result JSON are generated under `build/`.

## Report comparison

The current n=4 measurements are 58 cycles for single-cycle, 74 for pipeline and 33 for SoC. The report records 57, 74 and 33. The single-cycle harness waits until the program reaches the appended terminal address after the shifts, accounting for one extra cycle across the sweep.

Historical report counts are stored in `report-cycle-counts.csv`; regenerated results are in `validated-results.json`. Do not combine them as though they used identical termination conventions.

## Scope

This is directed simulation, not exhaustive formal verification. Coverage does not establish correctness for every instruction permutation, unaligned or out-of-range address, reset timing, repeated peripheral trigger sequence, or upper GPIO input bit pattern. No synthesis timing, resource utilization or FPGA hardware run was repeated.

Icarus emits warnings about design modules lacking a timescale, unused mux inputs and array sensitivity; these do not fail the checked workloads. The earlier standalone original pipeline compiles with implicit-net warnings. The original SoC testbench fails compilation due to a duplicate declaration. Original testbenches are archived for provenance and are not CI entrypoints.
