module soc_ad(
  input wire [31:0] A,
  input wire WE,
  output reg WE1,
  output reg WE2,
  output reg WEM,
  output reg [1:0] RdSel
    );
    
    always @ (*) begin
        WE1 = 1'b0;
        WE2 = 1'b0;
        WEM = 1'b0;
        RdSel = 2'b00;
        if (A >= 32'h0000_0000 && A <= 32'h0000_00FC) begin
            // Data Memory
            WEM = WE;   
            RdSel = 2'b00;
        end
        else if (A >= 32'h0000_0800 && A <= 32'h0000_080C) begin
            // Factorial Accelerator
            WE1 = WE;   
            RdSel = 2'b10;
        end
        else if (A >= 32'h0000_0900 && A <= 32'h0000_090C) begin
            // GPIO
            WE2 = WE;
            RdSel = 2'b11;
        end
    end
    
endmodule
