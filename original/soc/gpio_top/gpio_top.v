module gpio_top (
    input wire        clk,
    input wire        rst,
    input wire [1:0]  A,
    input wire        WE,
    input wire [31:0] WD,
    input wire [31:0] gpI1,
    input wire [31:0] gpI2,
    output reg [31:0] gpO1,
    output reg [31:0] gpO2,
    output reg [31:0] RD
);

    wire WE1, WE2;
    wire [1:0] RdSel;

    gpio_ad gpio_ad (
        .A(A),
        .WE(WE),
        .WE1(WE1),
        .WE2(WE2),
        .RdSel(RdSel)
    );

    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            gpO1 <= 32'b0;
            gpO2 <= 32'b0;
        end
        else
        begin
            if (WE1)
                gpO1 <= WD;
            if (WE2)
                gpO2 <= WD;
        end
    end

    always @(*)
    begin
        case (RdSel)
            2'b00: RD = gpI1;
            2'b01: RD = gpI2;
            2'b10: RD = gpO1;
            2'b11: RD = gpO2;
            default: RD = {31{1'bx}};
        endcase
    end

endmodule
