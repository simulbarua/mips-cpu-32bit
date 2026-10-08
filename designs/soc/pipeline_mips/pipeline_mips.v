module pipeline_mips (
        input  wire        clk,
        input  wire        rst,
        input  wire [31:0] instrF,
        input  wire [31:0] rd_dmM,
        output wire [31:0] pc_currentF,
        output wire [31:0] wd_dmM,
        output wire        we_dmM,
        output wire [31:0] alu_outM,
        
        // For debug
        input wire [4:0]  ra3,
        output wire [31:0] rd3
    );
    
    wire [31:0] branch_forwardA, branch_forwardB;
    wire we_dmE;

    // Internal Signals
    // IF Stage
    wire [31:0] pc_plus4F;
    
    // ID Stage
    wire        branchD;
    wire        jumpD;
    wire        reg_dstD;
    wire        we_regD;
    wire        we_dmD;
    wire        alu_srcD;
    wire        dm2regD;
    wire [2:0]  alu_ctrlD;
    wire        jalD;
    wire        jrD;
    wire        we_mult_regD;
    wire        mfhiD;
    wire        mfloD;
    wire [31:0] pc_plus4D;
    wire [31:0] instrD;
    wire [4:0]  alu_shamtD;
    wire        FlushD;
    
    
    
    // EX Stage
    wire        branchE;
    wire        reg_dstE;
    wire        we_regE;
    wire        alu_srcE;
    wire        dm2regE;
    wire [2:0]  alu_ctrlE;
    wire        jalE;
    wire [4:0]  rf_waE;
    wire        we_mult_regE;
    wire        mfhiE;
    wire        mfloE;
    wire [31:0] pc_plus4E;
    wire [4:0]  alu_shamtE;
    wire [4:0]  rsE;
    wire [4:0]  rtE;
    wire [4:0]  rdE;
    wire [31:0] wd_dmE;
    wire [31:0] alu_outE;
    wire [31:0] alu_pbE_forwarded;
    
    
    // MEM Stage
    wire        we_regM;
    wire        dm2regM;
    wire        jalM;
    wire [4:0]  rf_waM;
    wire [31:0] pc_plus4M;
    wire [31:0] resultM;
    wire [31:0] mult_rf_rdM;
    wire        mfhiM;
    wire        mfloM;
    wire        mf_hi_or_loM;
    
    // WB Stage
    wire        we_regW;
    wire        dm2regW;
    wire        jalW;
    wire [4:0]  rf_waW;
    wire [31:0] resultW;
    wire [31:0] pc_plus4W;
    wire        mfhiW;
    wire        mfloW;
    wire [31:0] rd_dmW;
    
    wire [4:0]  rf_wa_1E;
    wire [4:0]  rf_wa;
    wire        pc_srcD;
    

      
    wire [31:0] pc_preF;      
    wire [31:0] pc_nextF;
    wire [31:0] sext_immD;
    wire [31:0] sext_immE;
    wire [31:0] baD;
    wire [31:0] btaD;
    wire [31:0] jtaD;
    
    wire [31:0] rf_rd1D;
    wire [31:0] rf_rd2D;
    wire [31:0] rf_rd1E;
    wire [31:0] rf_rd2E;
    
    wire [31:0] alu_paE;
    wire [31:0] alu_pbE;
    wire        zero;
    wire [63:0] mult_outE;
    wire [31:0] mult_rf_rdE;
    wire [31:0] wd_rf_1;
    wire [31:0] wd_rf_2;
    wire [31:0] wd_rfW;
    wire [31:0] pc_next_preF;

    
    // Hazard Unit Signals
    wire StallF;
    wire StallD;
    wire FlushE;
    wire ForwardAD;
    wire ForwardBD;
    wire [1:0] ForwardAE;
    wire [1:0] ForwardBE;


       

    assign baD = {sext_immD[29:0], 2'b00};
    assign jtaD = {pc_plus4D[31:28], instrD[25:0], 2'b00};
    
    // Logical OR of mfhi and mflo signal to select hi/lo
    // register value as rf write data.
    assign mf_hi_or_loM = mfhiM || mfloM;
     
    
    // IF Stage
    dreg pc_reg (
            .clk            (clk),
            .rst            (rst),
            .en             (!StallF),   // Add hazard logic
            .d              (pc_nextF),
            .q              (pc_currentF)
        );

    adder pc_plus_4 (
            .a              (pc_currentF),
            .b              (32'd4),
            .y              (pc_plus4F)
        );
    
    // IF/ID Register
    if_id_pipeline_reg if_id_reg (
            .clk             (clk),
            .rst             (rst),
            .en              (!StallD), // Add stall logic later
            .clr             (FlushD), // Update later
            .instrF          (instrF),
            .pc_plus_4F      (pc_plus4F),
            .instrD          (instrD),
            .pc_plus_4D      (pc_plus4D) 
    );
    
    // ID Stage
    // Control unit
    controlunit cu (
            .opcode         (instrD[31:26]),
            .funct          (instrD[5:0]),
            .branch         (branchD),
            .jump           (jumpD),
            .reg_dst        (reg_dstD),
            .we_reg         (we_regD),
            .alu_src        (alu_srcD),
            .we_dm          (we_dmD),
            .dm2reg         (dm2regD),
            .alu_ctrl       (alu_ctrlD),
            .jal            (jalD),
            .jr             (jrD),
            .we_mult_reg    (we_mult_regD),
            .mfhi           (mfhiD),
            .mflo           (mfloD)
        );
    

    regfile rf (
            .clk            (clk),
            .we             (we_regW),
            .ra1            (instrD[25:21]),
            .ra2            (instrD[20:16]),
            .ra3            (ra3),
            .wa             (rf_waW),
            .wd             (wd_rfW),
            .rd1            (rf_rd1D),
            .rd2            (rf_rd2D),
            .rd3            (rd3),
            .rst            (rst)
        );

    signext se (
            .a              (instrD[15:0]),
            .y              (sext_immD)
        );
        
    
    // Logic for early branch determination
    wire [31:0] Forward_dataM;
    assign  Forward_dataM = jalM ? pc_plus4M : dm2regM ? rd_dmM : resultM;
    
    assign branch_forwardA = (ForwardAD == 1'b0) ? rf_rd1D : Forward_dataM;
    assign branch_forwardB = (ForwardBD == 1'b0) ? rf_rd2D : Forward_dataM;
    assign pc_srcD = branchD & (branch_forwardA == branch_forwardB);
    //assign FlushD = pc_srcD || jrD || jumpD;
        
    adder pc_plus_br (
            .a              (pc_plus4D),
            .b              (baD),
            .y              (btaD)
        );

    mux2 #(32) pc_src_mux (
            .sel            (pc_srcD),
            .a              (pc_plus4F),
            .b              (btaD),
            .y              (pc_preF)
        );

    mux2 #(32) pc_jmp_mux (
            .sel            (jumpD),
            .a              (pc_preF),
            .b              (jtaD),
            .y              (pc_next_preF)
        );
            
    // New: Mux to select the $ra value as next PC
    mux2 #(32) pc_jr_mux (
            .sel            (jrD),
            .a              (pc_next_preF),
            .b              (branch_forwardA),
            .y              (pc_nextF)
        );
        
        
    // ID/EX registers
    id_ex_pipeline_reg id_ex_reg(
            .clk             (clk),
            .rst             (rst),
            .en              (1'b1), // Add stall logic later
            .clr             (FlushE), // Update later
            
            // Inputs
            .reg_dstD        (reg_dstD),
            .we_regD         (we_regD),     
            .we_dmD          (we_dmD),
            .dm2regD         (dm2regD),
            .alu_ctrlD       (alu_ctrlD),
            .alu_srcD        (alu_srcD),
            .alu_shamtD      (instrD[10:6]),
            .we_mult_regD    (we_mult_regD),
            .mfhiD           (mfhiD),
            .mfloD           (mfloD),
            .jalD            (jalD),
            .rsD             (instrD[25:21]),
            .rtD             (instrD[20:16]), 
            .rdD             (instrD[15:11]),
            .rf_rd1D         (rf_rd1D),
            .rf_rd2D         (rf_rd2D),
            .pc_plus_4D      (pc_plus4D),
            .sext_immD       (sext_immD),
          
            // Outputs
            .reg_dstE        (reg_dstE),
            .we_regE         (we_regE),     
            .we_dmE          (we_dmE),
            .dm2regE         (dm2regE),
            .alu_ctrlE       (alu_ctrlE),
            .alu_srcE        (alu_srcE),
            .alu_shamtE      (alu_shamtE),
            .we_mult_regE    (we_mult_regE),
            .mfhiE           (mfhiE),
            .mfloE           (mfloE),
            .jalE            (jalE),
            .rsE             (rsE),
            .rtE             (rtE), 
            .rdE             (rdE),
            .rf_rd1E         (rf_rd1E),
            .rf_rd2E         (rf_rd2E),
            .pc_plus_4E      (pc_plus4E),
            .sext_immE       (sext_immE)
    );
    
    
    mux4 alu_pa_forward_mux (
            .sel            (ForwardAE),
            .a              (rf_rd1E),
            .b              (wd_rfW),
            .c              (Forward_dataM),
            .y              (alu_paE)
    );
    
    mux4 alu_pb_forward_mux (
            .sel            (ForwardBE),
            .a              (rf_rd2E),
            .b              (wd_rfW),
            .c              (Forward_dataM),
            .y              (wd_dmE)
    );
    

    // --- ALU Logic --- //
    mux2 #(32) alu_pb_mux (
            .sel            (alu_srcE),
            .a              (wd_dmE),
            .b              (sext_immE),
            .y              (alu_pbE)
        );

    alu alu (
            .op             (alu_ctrlE),
            .a              (alu_paE),
            .b              (alu_pbE),
            .shamt          (alu_shamtE),
            .zero           (),
            .y              (alu_outE)
        );
    
    
    // Combinational multiplier for MULTU instruction
    // Output is 64 bit multiplication result
    multiplier mult(
            .a              (alu_paE),  // Add hazard logic (alu_paE),
            .b              (alu_pbE),
            .y              (mult_outE)
        );
    
    // 
    // Multiplier register file containing hi and lo register
    // written only for MULTU instructions using we_mult_reg
    // control signals. Outputs hi for mfhi and lo for mflo.
    mult_rf hi_lo_rf(
            .clk            (clk),
            .rst            (rst),
            .we             (we_mult_regE),
            .mflo           (mfloE),
            .mfhi           (mfhiE),
            .wd             (mult_outE),
            .rd             (mult_rf_rdE)
        );
        
     mux2 #(5) rf_wa_mux1 (
            .sel            (reg_dstE),
            .a              (rtE),
            .b              (rdE),
            .y              (rf_wa_1E)
        );
        
    // MUX to select $ra as write address for JAL instructions
    mux2 #(5) rf_wa_mux2 (
            .sel            (jalE),
            .a              (rf_wa_1E),
            .b              (5'd31),
            .y              (rf_waE)
        );
        
    // EX/MEM Registers
    ex_mem_pipeline_reg ex_mem_reg(
            .clk             (clk),
            .rst             (rst),
            .en              (1'b1), // Add stall logic later
            .clr             (1'b0), // Update later
            
            .we_regE         (we_regE),
            .we_dmE          (we_dmE),
            .dm2regE         (dm2regE),
            .jalE            (jalE),
            .rf_waE          (rf_waE),
            .alu_outE        (alu_outE),
            .mult_rf_rdE     (mult_rf_rdE),
            .wd_dmE          (wd_dmE),
            .pc_plus_4E      (pc_plus4E),
            .mfhiE           (mfhiE),
            .mfloE           (mfloE),
            
            .we_regM         (we_regM),
            .we_dmM          (we_dmM),
            .dm2regM         (dm2regM),
            .jalM            (jalM),
            .rf_waM          (rf_waM),
            .alu_outM        (alu_outM),
            .mult_rf_rdM     (mult_rf_rdM),
            .wd_dmM          (wd_dmM),
            .pc_plus_4M      (pc_plus4M),
            .mfhiM           (mfhiM),
            .mfloM           (mfloM)
    );
    
    
     // MUX to select multiplicantion result Hi/Lo
    // as write data when either mfhi and mflo control]
    // signals are active.
    mux2 #(32) rf_wd_mux3 (
            .sel            (mf_hi_or_loM),
            .a              (alu_outM),
            .b              (mult_rf_rdM),
            .y              (resultM)
        );
                
    // MEM/WB Registers
    mem_wb_pipeline_reg mem_wb_reg(
            .clk             (clk),
            .rst             (rst),
            .en              (1'b1), // Add stall logic later
            .clr             (1'b0), // Update later
            
            .we_regM         (we_regM),
            .dm2regM         (dm2regM),
            .jalM            (jalM),
            .rf_waM          (rf_waM),
            .resultM         (resultM),
            .rd_dmM          (rd_dmM),
            .pc_plus_4M      (pc_plus4M),
            
            .we_regW         (we_regW),
            .dm2regW         (dm2regW),
            .jalW            (jalW),
            .rf_waW          (rf_waW),
            .resultW         (resultW),
            .rd_dmW          (rd_dmW),
            .pc_plus_4W      (pc_plus4W)
    );
   

    // --- MEM Logic --- //
    // MUX to select between alu and dm output using dm2reg
    mux2 #(32) rf_wd_mux1 (
            .sel            (dm2regW),
            .a              (resultW),
            .b              (rd_dmW),
            .y              (wd_rf_1)
        );
    // MUX to select PC+4 as write data for JAL
    // Should be in the WB
    mux2 #(32) rf_wd_mux2(
            .sel            (jalW),
            .a              (wd_rf_1),
            .b              (pc_plus4W),
            .y              (wd_rfW)
        );
        
        
    // Hazard Unit
    hazard_unit hazard(
            .branchD        (branchD),
            .pc_srcD        (pc_srcD),
            .rsD            (instrD[25:21]),
            .rtD            (instrD[20:16]),
            .rsE            (rsE),
            .rtE            (rtE),
            .we_regE        (we_regE),
            .dm2regE        (dm2regE),
            .rf_waE         (rf_waE),
            .we_regM        (we_regM),
            .dm2regM        (dm2regM),
            .rf_waM         (rf_waM),
            .rf_waW         (rf_waW),
            .we_regW        (we_regW),
            .StallF         (StallF),
            .StallD         (StallD),
            .ForwardAD      (ForwardAD), 
            .ForwardBD      (ForwardBD),
            .FlushE         (FlushE),
            .ForwardAE      (ForwardAE),
            .ForwardBE      (ForwardBE),
            
            .jrD            (jrD),
            .jalD           (jalD),
            .jumpD          (jumpD),
            .FlushD         (FlushD)
    );
    
endmodule