module if_id_pipeline_reg (
        input  wire        clk,
        input  wire        rst,
        input  wire        en,
        input  wire        clr,
        input  wire [31:0] instrF,
        input  wire [31:0] pc_plus_4F,
        output reg  [31:0] instrD,
        output reg  [31:0] pc_plus_4D 
    );

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
          instrD <= 32'b0;
          pc_plus_4D <= 32'b0;
        end
        else if (clr) begin
          instrD <= 32'b0;
          pc_plus_4D <= 32'b0;
        end
        else if (en) begin
          instrD <= instrF;
          pc_plus_4D <= pc_plus_4F;
        end
    end
endmodule