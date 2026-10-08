`timescale 1ns/1ps
module tb_cpu;
    reg clk=0, rst=0;
    reg [4:0] ra3=16;
    wire [31:0] pc, instr, addr, wd, rd, rd3;
    wire we;
    integer n, expected, cycles;
    always #5 clk=~clk;
    mips_top dut(.clk(clk), .rst(rst), .ra3(ra3), .rd3(rd3), .pc_current(pc), .instr(instr), .we_dm(we), .alu_out(addr), .wd_dm(wd), .rd_dm(rd));
    initial begin
        if (!$value$plusargs("N=%d",n)) n=4;
        if (!$value$plusargs("EXPECTED=%d",expected)) expected=24;
        #1 rst=1; #11 rst=0;
        for(cycles=0;cycles<3000;cycles=cycles+1) begin
            @(negedge clk);
            if(pc==32'h60) begin
                if(rd3 !== expected) $fatal(1,"factorial n=%0d expected=%0d got=%0d",n,expected,rd3);
                $display("PASS factorial n=%0d result=%0d cycles=%0d",n,rd3,cycles+1);
                $finish;
            end
        end
        $fatal(1,"CPU timeout n=%0d pc=%h",n,pc);
    end
endmodule
