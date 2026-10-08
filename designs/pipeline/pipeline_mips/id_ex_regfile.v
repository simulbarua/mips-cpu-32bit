module id_ex_pipeline_reg (
        input  wire        clk,
        input  wire        rst,
        input  wire        en,
        input  wire        clr,
        
        // ID side signals (inputs)
        // Control Signals
        input  wire        reg_dstD,
        input  wire        we_regD,
        input  wire        we_dmD,
        input  wire        dm2regD,
        input  wire [2:0]  alu_ctrlD,
        input  wire        alu_srcD,
        input  wire [4:0]  alu_shamtD,
        input  wire        we_mult_regD,
        input  wire        mfhiD,
        input  wire        mfloD,
        input  wire        jalD,
        // RF Addresses
        input  wire [4:0]  rsD,
        input  wire [4:0]  rtD,
        input  wire [4:0]  rdD,
        // RF Outputs
        input  wire [31:0] rf_rd1D,
        input  wire [31:0] rf_rd2D,
        // PC+4
        input  wire [31:0] pc_plus_4D,
        // sext_imm
        input  wire [31:0] sext_immD,
        
        // EX Side signals (outputs)
        output reg         reg_dstE,
        output reg         we_regE,
        output reg         we_dmE,
        output reg         dm2regE,
        output reg  [2:0]  alu_ctrlE,
        output reg         alu_srcE,
        output reg  [4:0]  alu_shamtE,
        output reg         we_mult_regE,
        output reg         mfhiE,
        output reg         mfloE,
        output reg         jalE,
        // RF Adresses
        output reg  [4:0] rsE,
        output reg  [4:0] rtE,
        output reg  [4:0] rdE,
        // RF Outputs
        output reg  [31:0] rf_rd1E,
        output reg  [31:0] rf_rd2E,
        // PC+4
        output reg  [31:0] pc_plus_4E,
        output reg [31:0] sext_immE
    );

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
          reg_dstE     <= 1'b0;
          we_regE      <= 1'b0;
          we_dmE       <= 1'b0;
          dm2regE      <= 1'b0;
          alu_ctrlE    <= 3'b0;
          alu_srcE     <= 1'b0;
          alu_shamtE   <= 5'b0;
          we_mult_regE <= 1'b0;
          mfhiE        <= 1'b0;
          mfloE        <= 1'b0;
          jalE         <= 1'b0;
          rsE          <= 5'b0;
          rtE          <= 5'b0;
          rdE          <= 5'b0;
          rf_rd1E      <= 32'b0;
          rf_rd2E      <= 32'b0;
          pc_plus_4E   <= 32'b0;
          sext_immE    <= 32'b0;
        end
        else if (clr) begin
          reg_dstE     <= 1'b0;
          we_regE      <= 1'b0;
          we_dmE       <= 1'b0;
          dm2regE      <= 1'b0;
          alu_ctrlE    <= 3'b0;
          alu_srcE     <= 1'b0;
          alu_shamtE   <= 5'b0;
          we_mult_regE <= 1'b0;
          mfhiE        <= 1'b0;
          mfloE        <= 1'b0;
          jalE         <= 1'b0;
          rsE          <= 5'b0;
          rtE          <= 5'b0;
          rdE          <= 5'b0;
          rf_rd1E      <= 32'b0;
          rf_rd2E      <= 32'b0;
          pc_plus_4E   <= 32'b0;
          sext_immE    <= 32'b0;
        end
        else if (en) begin
          reg_dstE     <= reg_dstD;
          we_regE      <= we_regD;
          we_dmE       <= we_dmD;
          dm2regE      <= dm2regD;
          alu_ctrlE    <= alu_ctrlD;
          alu_srcE     <= alu_srcD;
          alu_shamtE   <= alu_shamtD;
          we_mult_regE <= we_mult_regD;
          mfhiE        <= mfhiD;
          mfloE        <= mfloD;
          jalE         <= jalD;
          rsE          <= rsD;
          rtE          <= rtD;
          rdE          <= rdD;
          rf_rd1E      <= rf_rd1D;
          rf_rd2E      <= rf_rd2D;
          pc_plus_4E   <= pc_plus_4D;
          sext_immE    <= sext_immD;
        end
    end
endmodule