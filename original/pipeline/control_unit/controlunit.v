module controlunit (
        input  wire [5:0]  opcode,
        input  wire [5:0]  funct,
        output wire        branch,
        output wire        jump,
        output wire        reg_dst,
        output wire        we_reg,
        output wire        alu_src,
        output wire        we_dm,
        output wire        dm2reg,
        output wire        jal,
        output wire        jr,
        output wire [2:0]  alu_ctrl,
        output wire        we_mult_reg,
        output wire        mfhi,
        output wire        mflo
    );
    
    wire [1:0] alu_op;
    wire       we_reg_md;

    maindec md (
        .opcode         (opcode),
        .branch         (branch),
        .jump           (jump),
        .reg_dst        (reg_dst),
        .we_reg         (we_reg_md),
        .alu_src        (alu_src),
        .we_dm          (we_dm),
        .dm2reg         (dm2reg),
        .alu_op         (alu_op),
        .jal            (jal)
    );

    auxdec ad (
        .alu_op         (alu_op),
        .funct          (funct),
        .alu_ctrl       (alu_ctrl),
        .we_mult_reg    (we_mult_reg),
        .mfhi           (mfhi),
        .mflo           (mflo),
        .jr             (jr)
    );
    
    assign we_reg = we_reg_md && ~jr && ~we_mult_reg;

endmodule