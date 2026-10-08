module fact_top (
    input wire clk,
    input wire rst,
    input wire [1:0] A,
    input wire WE,
    input wire [3:0] WD,
    output reg [31:0] RD
);

    parameter nw = 4; // input n  is 4 bits wide

    wire WE1, WE2;
    wire [1:0] RdSel;
    wire [nw-1:0] n;
    wire Go;
    reg ResDone;
    reg ResErr;
    reg [31:0] Result;
    wire Done, Err;
    wire [31:0] nf;
    wire GoPulseCmb;

    fact_ad fact_ad (
        .A(A),
        .WE(WE),
        .WE1(WE1),
        .WE2(WE2),
        .RdSel(RdSel)
    );

    fact_reg #(.w(nw)) n_reg (
        .clk(clk),
        .rst(rst),
        .D(WD),
        .Load_Reg(WE1),
        .Q(n)
    );

    fact_reg #(.w(1)) go_reg (
        .clk(clk),
        .rst(rst),
        .D(WD[0]),
        .Load_Reg(WE2),
        .Q(Go)
    );

    assign GoPulseCmb = WD[0] & WE2;

    fact factorial_accelerator (
        .clk(clk),
        .rst(rst),
        .Go(Go),
        .n(n),
        .Done(Done),
        .Err(Err),
        .nf(nf)
    );

    always @(posedge clk or posedge rst)
    begin
        if (rst)
            ResDone <= 1'b0;
        else
            ResDone <= (~GoPulseCmb) & (Done | ResDone);
    end

    always @(posedge clk or posedge rst)
    begin
        if (rst)
            ResErr <= 1'b0;
        else
            ResErr <= (~GoPulseCmb) & (Err | ResErr);
    end

    always @(posedge clk or posedge rst)
    begin
        if (rst)
            Result <= 32'h0;
        else if (Done)
            Result <= nf;
    end

    always @(*)
    begin
        case (RdSel)
            2'b00: RD = {{(32-nw){1'b0}}, n};
            2'b01: RD = {{31{1'b0}}, Go};
            2'b10: RD = {{30{1'b0}}, ResErr, ResDone};
            2'b11: RD = Result;
            default: RD = {31{1'bx}};
        endcase
    end

endmodule
