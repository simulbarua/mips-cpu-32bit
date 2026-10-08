module ex_mem_pipeline_reg (
        input  wire        clk,
        input  wire        rst,
        input  wire        en,
        input  wire        clr,
        
        // EX Side signals (inputs)
        input wire         we_regE,
        input wire         we_dmE,
        input wire         dm2regE,
        input wire         jalE,
        // RF Adresses
        input wire  [4:0] rf_waE,
        // RF Outputs
        input wire  [31:0] alu_outE,
        input wire  [31:0] mult_rf_rdE,
        input wire  [31:0] wd_dmE,
        input wire         mfhiE,
        input wire         mfloE,
        
        // PC+4
        input wire  [31:0] pc_plus_4E,
        
        
        // MEM Side signals (outputs)
        output reg         we_regM,
        output reg         we_dmM,
        output reg         dm2regM,
        output reg         jalM,
        // RF Adresses
        output reg  [4:0]  rf_waM,
        // RF Outputs
        output reg  [31:0] alu_outM,
        output reg  [31:0] mult_rf_rdM,
        output reg  [31:0] wd_dmM,
        output reg         mfhiM,
        output reg         mfloM,
        
        // PC+4
        output reg  [31:0] pc_plus_4M
    );

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
          we_regM      <= 1'b0;
          we_dmM       <= 1'b0;
          dm2regM      <= 1'b0;
          jalM         <= 1'b0;
          rf_waM       <= 5'b0;
          alu_outM     <= 32'b0;
          mult_rf_rdM  <= 32'b0;
          wd_dmM       <= 32'b0;
          pc_plus_4M   <= 32'b0;
          mfhiM        <= 1'b0;
          mfloM        <= 1'b0;
        end
        else if (clr) begin
          we_regM      <= 1'b0;
          we_dmM       <= 1'b0;
          dm2regM      <= 1'b0;
          jalM         <= 1'b0;
          rf_waM       <= 5'b0;
          alu_outM     <= 32'b0;
          mult_rf_rdM  <= 32'b0;
          wd_dmM       <= 32'b0;
          pc_plus_4M   <= 32'b0;
          mfhiM        <= 1'b0;
          mfloM        <= 1'b0;     
        end
        else if (en) begin
          we_regM      <= we_regE;
          we_dmM       <= we_dmE;
          dm2regM      <= dm2regE;
          jalM         <= jalE;
          rf_waM       <= rf_waE;
          alu_outM     <= alu_outE;
          mult_rf_rdM  <= mult_rf_rdE;
          wd_dmM       <= wd_dmE;
          pc_plus_4M   <= pc_plus_4E;
          mfhiM        <= mfhiE;
          mfloM        <= mfloE;
        end
    end
endmodule