module tb_mips_top;

    reg         clk;
    reg         rst;
    wire        we_dm;
    wire [31:0] pc_current;
    wire [31:0] instr;
    wire [31:0] alu_out;
    wire [31:0] wd_dm;
    wire [31:0] rd_dm;
    wire [31:0] rd3;
    reg [4:0]  ra3;
    
    integer i;
    reg found_return;
    
    mips_top DUT (
            .clk            (clk),
            .rst            (rst),
            .we_dm          (we_dm),
            .ra3            (ra3),
            .pc_current     (pc_current),
            .instr          (instr),
            .alu_out        (alu_out),
            .wd_dm          (wd_dm),
            .rd_dm          (rd_dm),
            .rd3            (rd3)
        );
    integer cycle_count;
    
    
    task tick;
    begin 
        clk = 1'b0; #5;
        clk = 1'b1; #5;
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
    
    
    
    
    initial begin
        ra3 = 32'd16;
        $display("@%0t :: Test started for the enhanced MIPS CPU.", $time);
        reset;
        cycle_count = 0;
        found_return = 0;
        
        while (pc_current != 32'h10) begin
            tick();
        end
        
        repeat(4) tick();
        $display("@%0t :: Test finished for the Pipeline MIPS CPU: %0d", $time, cycle_count);
        $finish;
    end

endmodule