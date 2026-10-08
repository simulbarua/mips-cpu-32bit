module tb_mips_top;
    reg         clk;
    reg         rst;
    reg [31:0] gpI1;
    reg [31:0] gpI2;
    wire [31:0] gpO1;
    wire [31:0] gpO2;
    
    reg  [4:0]  ra3;
    wire [31:0] rd3;
    wire [31:0] pc_current;
    
    
    integer i;
    
    soc_top soc_top (
            .clk            (clk),
            .rst            (rst),
            .gpI1           (gpI1),
            .gpI2           (gpI2),
            .gpO1           (gpO1),
            .gpO2           (gpO2),
            .ra3            (ra3),
            .rd3            (rd3),
            .PC             (pc_current)
        );
    
    integer cycle_count;
    
    task tick; 
    begin 
        clk = 1'b1; #5;
        clk = 1'b0; #5;
        cycle_count = cycle_count + 1;
    end
    endtask

    task reset;
    begin 
        rst = 1'b0; #5;
        rst = 1'b1; #5;
        rst = 1'b0;
    end
    endtask
    
    // Function to calculate the factorial (expected result)
    function [31:0] calc_factorial;
        input integer n;
        integer i;
        begin
            calc_factorial = 1;
            for (i = n; i >= 1; i = i - 1)
                calc_factorial = calc_factorial * i;
        end
    endfunction
    
    // Other Variables
    integer i;
    integer pass = 0;
    integer fail = 0;
    reg [31:0] gpO1_exp;
    reg [31:0] gpO2_exp;
    
    initial begin
        $display("@%0t :: Test started for SoC", $time);
        ra3 = 5'd10;
        for (i = 0; i < 16; i=i+1) begin
            reset;
            cycle_count = 0;
            gpI1 = i;
            if (i > 12) begin
                gpO2_exp = 32'h0;
                gpO1_exp = 32'h1;
            end
            else begin
                gpO2_exp = calc_factorial(i);
                gpO1_exp = 32'h0;
            end
            while (pc_current != 32'h40) begin
                tick();
            end
            repeat(4) tick();
            // Compare results
            if ((gpO2 === gpO2_exp) && (gpO1 === gpO1_exp)) begin
                $display("[PASS] @%0tns: gpI1=%0d :: expected gpO1=0x%0h, computed gpO1=0x%0h", $time, gpI1, gpO1_exp, gpO1);
                $display("[PASS] @%0tns: gpI1=%0d :: expected gpO2=0x%0h, computed gpO2=0x%0h", $time, gpI1, gpO2_exp, gpO2);
                $display("[INFO] Total clock cycle count: %0d", cycle_count);
                pass = pass+1;
            end
            else begin
                $display("[FAIL] @%0tns: gpI1=%0d :: expected gpO1=0x%0h, computed gpO1=0x%0h", $time, gpI1, gpO1_exp, gpO1);
                $display("[FAIL] @%0tns: gpI1=%0d :: expected gpO2=0x%0h, computed gpO2=0x%0h", $time, gpI1, gpO2_exp, gpO2);
                fail = fail+1;
            end
        end
        
        $display("[INFO] SUMMARY: Total Tests: %0d, Total Passed: %0d, Total Failed: %0d", pass+fail, pass, fail);
        $finish;
    end

endmodule