module auxdec (
        input  wire [1:0] alu_op,
        input  wire [5:0] funct,
        output wire [2:0] alu_ctrl,
        output reg        we_mult_reg,
        output reg        mfhi,
        output reg        mflo,
        output reg        jr
    );

    reg [2:0] ctrl;

    assign {alu_ctrl} = ctrl;
    
    always @ (alu_op, funct) begin
        we_mult_reg = 1'b0;
        mfhi = 1'b0;
        mflo = 1'b0;
        jr = 1'b0;
        case (alu_op)
            2'b00: ctrl = 3'b010;            // ADD
            2'b01: ctrl = 3'b110;            // SUB
            default: case (funct)
                6'b00_0000: ctrl = 3'b100;   // SLL
                6'b00_0010: ctrl = 3'b101;   // SRL
                6'b10_0100: ctrl = 3'b000;   // AND
                6'b10_0101: ctrl = 3'b001;   // OR
                6'b10_0000: ctrl = 3'b010;   // ADD
                6'b10_0010: ctrl = 3'b110;   // SUB
                6'b10_1010: ctrl = 3'b111;   // SLT
                6'b01_1001: begin            // MULTU
                            we_mult_reg = 1;
                            ctrl = 3'bxxx; 
                        end
                6'b01_0000: begin            // MFHI
                            mfhi = 1;
                            ctrl = 3'bxxx; 
                        end
                6'b01_0010: begin            // MFLO
                            mflo = 1;
                            ctrl = 3'bxxx; 
                        end
                6'b00_1000: begin            // JR  
                            jr = 1;
                            ctrl = 3'bxxx; 
                        end
                default:    ctrl = 3'bxxx;
            endcase
        endcase
    end

endmodule