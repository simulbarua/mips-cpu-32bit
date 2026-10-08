# Assembly exercises

Recovered `.asm` files from Assignments 2–4 complement the CPU designs: ISA instruction tracing, arithmetic and HI/LO use, iterative factorial, arrays and recursive stack frames. Original filenames and content are retained and hashed in the source manifest.

These MARS-oriented exercises may use simulator memory layouts, larger arrays or assembler features beyond the small RTL CPU ROM/RAM. They are reference programs, not additional programs validated by `scripts/test.py`.

The CPU-ready recursive factorial program is in `designs/single-cycle/factorial.asm`; its assembled words are in each CPU's `memfile.mem`. The SoC ROM implements peripheral operand submission, status polling and GPIO output.
