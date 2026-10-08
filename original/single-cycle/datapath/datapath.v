module datapath (
        input  wire        clk,
        input  wire        rst,
        input  wire        branch,
        input  wire        jump,
        input  wire        reg_dst,
        input  wire        we_reg,
        input  wire        alu_src,
        input  wire        dm2reg,
        input  wire [2:0]  alu_ctrl,
        input  wire        jal,
        input  wire        jr,
        input  wire        we_mult_reg,
        input  wire        mfhi,
        input  wire        mflo,
        input  wire [4:0]  ra3,
        input  wire [31:0] instr,
        input  wire [31:0] rd_dm,
        output wire [31:0] pc_current,
        output wire [31:0] alu_out,
        output wire [31:0] wd_dm,
        output wire [31:0] rd3
    );
    wire [4:0]  rf_wa_1;
    wire [4:0]  rf_wa;
    wire        pc_src;
    wire [31:0] pc_plus4;
    wire [31:0] pc_pre;      
    wire [31:0] pc_next;
    wire [31:0] sext_imm;
    wire [31:0] ba;
    wire [31:0] bta;
    wire [31:0] jta;
    wire [31:0] alu_pa;
    wire [31:0] alu_pb;
    wire        zero;
    wire [63:0] mult_out;
    wire [31:0] mult_rf_rd;
    wire [31:0] wd_rf_1;
    wire [31:0] wd_rf_2;
    wire [31:0] wd_rf;
    wire [31:0] pc_next_pre;
    wire        mf_hi_or_lo;
    
    assign pc_src = branch & zero;
    assign ba = {sext_imm[29:0], 2'b00};
    assign jta = {pc_plus4[31:28], instr[25:0], 2'b00};
    
    // Logical OR of mfhi and mflo signal to select hi/lo
    // register value as rf write data.
    assign mf_hi_or_lo = mfhi | mflo;
    
    // --- PC Logic --- //
    dreg pc_reg (
            .clk            (clk),
            .rst            (rst),
            .d              (pc_next),
            .q              (pc_current)
        );

    adder pc_plus_4 (
            .a              (pc_current),
            .b              (32'd4),
            .y              (pc_plus4)
        );

    adder pc_plus_br (
            .a              (pc_plus4),
            .b              (ba),
            .y              (bta)
        );

    mux2 #(32) pc_src_mux (
            .sel            (pc_src),
            .a              (pc_plus4),
            .b              (bta),
            .y              (pc_pre)
        );

    mux2 #(32) pc_jmp_mux (
            .sel            (jump),
            .a              (pc_pre),
            .b              (jta),
            .y              (pc_next_pre)
        );
    
    // New: Mux to select the $ra value as next PC
    mux2 #(32) pc_jr_mux (
            .sel            (jr),
            .a              (pc_next_pre),
            .b              (alu_pa),
            .y              (pc_next)
        );    
    

    // --- RF Logic --- //
    // 
    mux2 #(5) rf_wa_mux1 (
            .sel            (reg_dst),
            .a              (instr[20:16]),
            .b              (instr[15:11]),
            .y              (rf_wa_1)
        );
        
    // MUX to select $ra as write address for JAL instructions
    mux2 #(5) rf_wa_mux2 (
            .sel            (jal),
            .a              (rf_wa_1),
            .b              (5'd31),
            .y              (rf_wa)
        );
        
    

    regfile rf (
            .clk            (clk),
            .we             (we_reg),
            .ra1            (instr[25:21]),
            .ra2            (instr[20:16]),
            .ra3            (ra3),
            .wa             (rf_wa),
            .wd             (wd_rf),
            .rd1            (alu_pa),
            .rd2            (wd_dm),
            .rd3            (rd3),
            .rst            (rst)
        );

    signext se (
            .a              (instr[15:0]),
            .y              (sext_imm)
        );

    // --- ALU Logic --- //
    mux2 #(32) alu_pb_mux (
            .sel            (alu_src),
            .a              (wd_dm),
            .b              (sext_imm),
            .y              (alu_pb)
        );

    alu alu (
            .op             (alu_ctrl),
            .a              (alu_pa),
            .b              (alu_pb),
            .shamt          (instr[10:6]),
            .zero           (zero),
            .y              (alu_out)
        );
    
    // Combinational multiplier for MULTU instruction
    // Output is 64 bit multiplication result
    multiplier mult(
            .a              (alu_pa),
            .b              (wd_dm),
            .y              (mult_out)
        );
    
    // Multiplier register file containing hi and lo register
    // written only for MULTU instructions using we_mult_reg
    // control signals. Outputs hi for mfhi and lo for mflo.
    mult_rf hi_lo_rf(
            .clk            (clk),
            .rst            (rst),
            .we             (we_mult_reg),
            .mflo           (mflo),
            .mfhi           (mfhi),
            .wd             (mult_out),
            .rd             (mult_rf_rd)
        );

    // --- MEM Logic --- //
    // MUX to select between alu and dm output using dm2reg
    mux2 #(32) rf_wd_mux1 (
            .sel            (dm2reg),
            .a              (alu_out),
            .b              (rd_dm),
            .y              (wd_rf_1)
        );
    // MUX to select PC+4 as write data for JAL
    mux2 #(32) rf_wd_mux2(
            .sel            (jal),
            .a              (wd_rf_1),
            .b              (pc_plus4),
            .y              (wd_rf_2)
        );
   
    // MUX to select multiplicantion result Hi/Lo
    // as write data when either mfhi and mflo control]
    // signals are active.
    mux2 #(32) rf_wd_mux3 (
            .sel            (mf_hi_or_lo),
            .a              (wd_rf_2),
            .b              (mult_rf_rd),
            .y              (wd_rf)
        );

endmodule