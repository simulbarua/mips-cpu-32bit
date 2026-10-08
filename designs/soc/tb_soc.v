`timescale 1ns/1ps
module tb_soc;
    reg clk=0,rst=0;
    reg [31:0] gpI1=0,gpI2=0;
    wire [31:0] gpO1,gpO2,pc,rd3;
    integer n,expected,cycles;
    always #5 clk=~clk;
    soc_top dut(.clk(clk),.rst(rst),.gpI1(gpI1),.gpI2(gpI2),.gpO1(gpO1),.gpO2(gpO2),.ra3(5'd10),.rd3(rd3),.PC(pc));
    initial begin
        if (!$value$plusargs("N=%d",n)) n=4;
        if (!$value$plusargs("EXPECTED=%d",expected)) expected=24;
        gpI1=n;
        #1 rst=1; #11 rst=0;
        for(cycles=0;cycles<1000;cycles=cycles+1) begin
            @(negedge clk);
            if(pc==32'h40) begin
                repeat(4) @(negedge clk);
                if(gpO1 !== ((n>12)?32'd1:32'd0) || gpO2 !== expected)
                    $fatal(1,"SoC n=%0d status=%0d result=%0d expected=%0d",n,gpO1,gpO2,expected);
                $display("PASS soc n=%0d result=%0d cycles=%0d",n,gpO2,cycles+5);
                $finish;
            end
        end
        $fatal(1,"SoC timeout n=%0d pc=%h",n,pc);
    end
endmodule
