# Architecture

## Single-cycle CPU

`mips_top` integrates `mips`, instruction ROM and data RAM. `mips` joins the control unit and datapath. A debug read port selects a general-purpose register without changing normal instruction operands.

The datapath computes PC+4, branch target and jump target, reads two register operands, selects the ALU's register/immediate input, and selects ALU or memory data for register writeback. `jal` writes PC+4 to register 31. `jr` selects the first register operand as next PC. `multu` writes a 64-bit unsigned product into HI/LO; `mfhi` and `mflo` select the corresponding half for writeback.

## Five-stage pipeline

| Stage | Work | Register boundary |
|---|---|---|
| IF | Fetch instruction and choose next PC | IF/ID: instruction, PC+4 |
| ID | Decode, register reads, sign extension, branch compare and jump targets | ID/EX: operands, immediates, register indices and execution controls |
| EX | ALU, multiplication, HI/LO access, destination selection | EX/MEM: result, store data, destination and memory/writeback controls |
| MEM | RAM/peripheral interface, select ALU or HI/LO result | MEM/WB: result, memory read data, link address and register controls |
| WB | Select result and write general-purpose register | Register file |

The register file bypasses the current WB data to simultaneous ID reads. EX operands can come from the captured register values, MEM or WB. MEM wins when both later stages target the same source register because it contains the newer value. MEM forwarding includes a `jal` link address.

Branches are compared in ID using full 32-bit operands, with MEM forwarding. Register jumps use that same forwarded first operand. Load-use and branch/register-jump dependencies stall PC and IF/ID, and insert a bubble into ID/EX. A control transfer flushes IF/ID only when decode can advance. Taken branches flush the sequentially fetched instruction.

## SoC address map

| Byte address | Register | Behavior |
|---|---|---|
| 0x000–0x0FC | Data RAM | 64 words, load/store |
| 0x800 | Factorial operand | Write low four bits of n |
| 0x804 | Factorial control | Write Go bit |
| 0x808 | Factorial status | Read Done bit 0 and Err bit 1 |
| 0x80C | Factorial result | Read 32-bit factorial result |
| 0x900 | GPIO input 1 | Read `gpI1` |
| 0x904 | GPIO input 2 | Read `gpI2` |
| 0x908 | GPIO output 1 | Write `gpO1` |
| 0x90C | GPIO output 2 | Write `gpO2` |

The included software uses `gpO1` for status/error and `gpO2` for the factorial result. With input bits above bit 3 clear, inputs 0–12 produce a result and status zero; inputs 13–15 produce error one and result zero. Upper input bits have separate selection/status meaning in the original program and are not covered by the current input sweep.

Instruction ROM and RAM select words with address bits [7:2]. That is six address bits, supporting 64 32-bit words. Standalone memory wrappers discard higher address bits, and unaligned accesses are not trapped. The SoC decoder selects RAM/peripherals using the full address before accessing a register within the selected block.

## Limits

No byte/halfword access, interrupts, exceptions, caches, MMU or architectural delay slots are implemented. Arithmetic overflow does not raise exceptions. `slt` uses signed comparison in the maintained versions. No FPGA placement/routing or maximum clock-frequency result is asserted by this repository.
