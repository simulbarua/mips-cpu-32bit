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
        input wire  [4:0]  rf_waM,
        // RF Outputs
        input wire  [31:0] resultM,
        input wire  [31:0] rd_dmM,
        
        // PC+4
        input wire  [31:0] pc_plus_4M,
        
        
        // MEM Side signals (outputs)
        output reg         we_regW,
        output reg         dm2regW,
        output reg         jalW,
        // RF Adresses
        output reg  [4:0]  rf_waW,
        // RF Outputs
        output reg  [31:0] resultW,
        output reg  [31:0] rd_dmW,
        
        // PC+4
        output reg  [31:0] pc_plus_4W
    );

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
          we_regW      <= 1'b0;
          dm2regW      <= 1'b0;
          jalW         <= 1'b0;
          rf_waW       <= 5'b0;
          resultW      <= 32'b0;
          rd_dmW       <= 32'b0;
          pc_plus_4W   <= 32'b0;
        end
        else if (clr) begin
          we_regW      <= 1'b0;
          dm2regW      <= 1'b0;
          jalW         <= 1'b0;
          rf_waW       <= 5'b0;
          resultW      <= 32'b0;
          rd_dmW       <= 32'b0;
          pc_plus_4W   <= 32'b0;
        end
        else if (en) begin
          we_regW      <= we_regM;
          dm2regW      <= dm2regM;
          jalW         <= jalM;
          rf_waW       <= rf_waM;
          resultW      <= resultM;
          rd_dmW       <= rd_dmM;
          pc_plus_4W   <= pc_plus_4M;
        end
    end
endmodule