# Restoration changes

The files in `original/` preserve the recovered source bytes. `docs/source-manifest.json` provides provenance and hashes. The `designs/` directories are maintained copies; the following changes were made during repository reconstruction, after the Spring 2025 work.

| Area | Recovered behavior | Maintained behavior |
|---|---|---|
| Pipeline branch operands | Undeclared nets default to one bit | Explicit 32-bit declarations |
| Pipeline memory control | `we_dmE` implicitly declared | Explicit declaration |
| SoC interconnect controls | Implicit one-bit nets | Explicit declarations |
| Register jump target | Raw register read despite hazard forwarding signals | Forwarded ID operand |
| MEM operand forwarding | Link addresses absent | `jal` PC+4 participates |
| EX forwarding priority | WB assignments override MEM matches | Newer MEM result has priority |
| Branch flushing | Only unconditional transfers flush | Taken branches also flush |
| Control flush during stall | May discard stalled jump instruction | Flush gated by decode advancing |
| `jr` after load | EX dependency covered, MEM load dependency omitted | MEM load dependency also stalls |
| ALU sensitivity | Shift amount excluded from sensitivity list | Combinational `always @ (*)` |
| `slt` | Unsigned comparison | Signed comparison |
| Verification | Unbounded or observational original testbenches | Bounded assertions against reference outputs |

The maintained standalone pipeline uses the final CPU from the recovered SoC snapshot, together with instruction/data memory and a new verification wrapper. Its ROM program is the enhanced single-cycle factorial program. The earlier standalone implementation remains available separately.

The tests modify only generated ROM images under `build/`: the factorial argument is replaced for each case, a terminal jump is appended, and unused CPU ROM words are filled with NOPs. The saved program files remain unchanged.

The current harness avoids the original SoC testbench's duplicate variable declaration and the single-cycle testbench's unreachable, unaligned termination address. It tests each SoC input in a fresh simulation to make reset and cycle accounting consistent.

These are documented fixes to restored copies, not claims that the saved original RTL already passed these focused tests. There is no recovered Git history establishing the order or dates of the source snapshots.
