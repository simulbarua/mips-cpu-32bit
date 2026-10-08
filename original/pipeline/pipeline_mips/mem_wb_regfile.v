module mem_wb_pipeline_reg (
        input  wire        clk,
        input  wire        rst,
        input  wire        en,
        input  wire        clr,
        
        // EX Side signals (inputs)
        input wire         we_regM,
        input wire         dm2regM,
        input wire         jalM,
        // RF Adresses
        input wire  [4:0] rf_waM,
        // RF Outputs
        input wire  [31:0] alu_outM,
        input wire  [31:0] mult_rf_rdM,
        input wire  [31:0] rd_dmM,
        input wire         mfhiM,
        input wire         mfloM,
        
        // PC+4
        input wire  [31:0] pc_plus_4M,
        
        
        // MEM Side signals (outputs)
        output reg         we_regW,
        output reg         dm2regW,
        output reg         jalW,
        // RF Adresses
        output reg  [4:0]  rf_waW,
        // RF Outputs
        output reg  [31:0] alu_outW,
        output reg  [31:0] mult_rf_rdW,
        output reg  [31:0] rd_dmW,
        output reg         mfhiW,
        output reg         mfloW,
        
        // PC+4
        output reg  [31:0] pc_plus_4W
    );

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
          we_regW      <= 1'b0;
          dm2regW      <= 1'b0;
          jalW         <= 1'b0;
          rf_waW       <= 5'b0;
          alu_outW     <= 32'b0;
          mult_rf_rdW  <= 32'b0;
          rd_dmW       <= 32'b0;
          pc_plus_4W   <= 32'b0;
          mfhiW        <= 1'b0;
          mfloW        <= 1'b0;
        end
        else if (clr) begin
          we_regW      <= 1'b0;
          dm2regW      <= 1'b0;
          jalW         <= 1'b0;
          rf_waW       <= 5'b0;
          alu_outW     <= 32'b0;
          mult_rf_rdW  <= 32'b0;
          rd_dmW       <= 32'b0;
          pc_plus_4W   <= 32'b0;
          mfhiW        <= 1'b0;
          mfloW        <= 1'b0;
        end
        else if (en) begin
          we_regW      <= we_regM;
          dm2regW      <= dm2regM;
          jalW         <= jalM;
          rf_waW       <= rf_waM;
          alu_outW     <= alu_outM;
          mult_rf_rdW  <= mult_rf_rdM;
          rd_dmW       <= rd_dmM;
          pc_plus_4W   <= pc_plus_4M;
          mfhiW        <= mfhiM;
          mfloW        <= mfloM;
        end
    end
endmodule