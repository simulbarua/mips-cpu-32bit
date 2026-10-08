module mult_rf (
        input  wire        clk,
        input  wire        rst,
        input  wire        we,
        input  wire        mfhi,
        input  wire        mflo,
        input  wire [63:0] wd,
        output wire [31:0] rd
    );

    reg [31:0] rf [0:1];
    reg [31:0] rd_int;

    integer n;
    
//    initial begin
//        rf[0] = 32'h0;
//        rf[1] = 32'h0;
//    end
    
    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            rf[0] = 32'h0;
            rf[1] = 32'h0;
        end
        else if (we) begin
            rf[0] = wd[31:0];
            rf[1] = wd[63:32];
        end
    end
    
    always @(*) begin
        if (mfhi) rd_int = rf[1];
        else if (mflo) rd_int = rf[0];
        else rd_int = 32'h0;
    end
    
    assign rd = rd_int;



endmodule