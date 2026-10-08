# Project development and source analysis

## Evidence and interpretation

This analysis uses the project reports as historical evidence and the recovered RTL as implementation evidence. Assignment handouts describe requirements; they do not establish that a feature was implemented or verified. Report claims are distinguished from current simulation results. The original reports remain in the local source archive and are not uploaded.

| Assignment | Report evidence | Work represented |
|---|---|---|
| 1 | `Assignment1/Assignment01.pdf`, pp. 2 onward | Factorial hardware organized as control unit plus datapath, FSM sequencing, self-checking verification in Vivado 2024.2 |
| 2 | `Assignment2/Assignment02_report.pdf`, pp. 2–5 | MARS/MIPSASM instruction execution, machine encoding comparisons, register and memory tracing |
| 3 | `Assignment3/Assignment3.pdf`, pp. 2 onward | Arithmetic assembly, multiplication and HI/LO, factorial program, stepwise test logs |
| 4 | `Assignment4/Assignment4.pdf`, pp. 2 onward | Arrays, stack frames, recursive calls, return addresses and recursive factorial |
| 5 | `Assignment5/Assignment5.pdf`, pp. 2–6 | Review and verification of provided single-cycle RTL; architectural diagrams and waveform analysis |
| 6 | `Assignment6/Assignment_6_report.pdf`, pp. 2–6 | Extended single-cycle CPU with `multu`, `mfhi`, `mflo`, `jal`, `jr`, `sll` and `srl` |
| 7 | `Assignment7/CMPE_200_Assignment_7.pdf`, pp. 2–14 and Appendix G | Five-stage pipeline, forwarding, stalls and flushes; factorial/GPIO SoC integration; cycle-count comparison |

## Design progression

The assembly exercises explain the later hardware choices. Recursive factorial requires saving the input and return address, updating the stack pointer, calling with `jal`, returning with `jr`, and moving multiplication results out of LO. Assignment 6 extends the CPU specifically to execute these operations, with shifts added to exercise the ALU changes.

The single-cycle implementation divides responsibility between a datapath and a control unit. The main decoder interprets the opcode and the auxiliary decoder handles R-type function fields. The extensions add a multiplier, HI/LO registers, writeback selection, `$ra` destination selection and a register-based PC path.

Assignment 7 moves execution into IF, ID, EX, MEM and WB stages. The important work is not just adding registers: it involves carrying the correct control bits with each instruction, selecting forwarded values, deciding when operands are unavailable, preserving the stalled instruction and invalidating wrong-path work. The final CPU saved in the SoC directory routes ALU/HI-LO values through `resultM` and `resultW`, matching the final report more closely than the earlier standalone pipeline snapshot.

The SoC adds an address decoder and memory-mapped registers. Software reads an input from GPIO, submits it to the factorial accelerator, polls completion and writes status/result to GPIO outputs. This demonstrates the hardware/software interface as well as instruction execution.

## Historical verification claims

Assignment 6 reports factorial(4)=24 and checks shift-left and shift-right operations. It explicitly notes that `mfhi` was not exercised by the main factorial program. The original single-cycle testbench has an unbounded wait for PC `0x16`, which is not word-aligned; it should not be used as the repository's verification entrypoint.

Assignment 7 reports the same factorial result, discusses branch stalls and forwarding, and exercises load-use hazards in the SoC polling program. Its Appendix G records cycle counts for n=0–12. The standalone pipeline testbench monitors termination but does not assert the computed result. The saved SoC testbench contains a duplicate `integer i` declaration that Icarus rejects.

The maintained tests assert output values, enforce cycle bounds, and add focused checks for corner cases absent from the recursive factorial workload. A passing workload is evidence for that workload, not proof of complete ISA or hazard correctness.

## Performance interpretation

For n≥2, the report records single-cycle counts of `14n + 1` and pipeline counts of `18n + 2`. For n=0 and n=1 the counts are 15 and 20 respectively. SoC counts are 28, 33 or 38 across the valid input range, reflecting polling/computation intervals.

The pipelined implementation uses more cycles on this recursive workload. A shorter pipeline clock could compensate, but no measured frequencies or synthesis timing results were recovered. At n=4, the reported pipeline would require a clock period below approximately 57/74 ≈ 0.770 of the single-cycle period to finish sooner under those cycle-count conventions. Actual speedup remains unmeasured.

## Recovered source selection

- Baseline: `Assignment5/Assignment5_processor_design_1/single_cycle_mips_source_initial`.
- Enhanced single-cycle: `Assignment6/VerilogFiles/single_cycle_mips_source_final`.
- Earlier standalone pipeline: `Assignment7/pipeline_mips`.
- Final pipeline and SoC integration: `Assignment7/soc_design_files`.

Other directories contain initial imports, intermediate projects and duplicate modules. They were not merged indiscriminately. The manifest records every retained original file's path relative to the assignments directory and SHA-256 hash.
