module mult_rf (
        input  wire        clk,
        input  wire        rst,
        input  wire        we,
        input  wire        mfhi,
        input  wire        mflo,
        input  wire [63:0] wd,
        output wire [31:0] rd
    );

    reg [31:0] hi_reg, lo_reg;
    
    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            hi_reg <= 32'h0;
            lo_reg <= 32'h0;
        end
        else if (we) begin
            hi_reg <= wd[63:32];
            lo_reg <= wd[31:0];
        end
    end
    
    
    assign rd = mfhi ? hi_reg :
                mflo ? lo_reg :
                32'd0;
endmodule