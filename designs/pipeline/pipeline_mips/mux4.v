module mux4 #(
    parameter WIDTH = 32
) (
    input  [1:0]           sel,
    input  [WIDTH-1:0]     a,
    input  [WIDTH-1:0]     b,
    input  [WIDTH-1:0]     c,
    input  [WIDTH-1:0]     d,
    output reg [WIDTH-1:0] y
);

  // combinational mux
  always @(*) begin
    case (sel)
      2'b00: y = a;
      2'b01: y = b;
      2'b10: y = c;
      2'b11: y = d;
      default: y = {WIDTH{1'bx}};
    endcase
  end

endmodule