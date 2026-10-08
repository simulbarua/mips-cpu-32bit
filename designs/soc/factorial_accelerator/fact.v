module fact (
    input wire clk,
    input wire rst,
    input wire Go,
    input wire [3:0] n,
    output reg Done,
    output reg Err,
    output reg [31:0] nf
);

    reg [1:0] state;
    reg [3:0] counter;
    reg [31:0] temp_nf;

    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            state <= 2'b00;
            Done <= 1'b0;
            Err <= 1'b0;
            nf <= 32'h0;
            counter <= 4'h0;
            temp_nf <= 32'h0;
        end
        else
        begin
            case (state)
                2'b00:
                begin // IDLE
                    Done <= 1'b0;
                    Err <= 1'b0;
                    if (Go)
                    begin
                        if (n > 4'd12)
                        begin
                            state <= 2'b10; // DONE
                            Done <= 1'b1;
                            Err <= 1'b1;
                            nf <= 32'h0;
                        end
                        else
                        begin
                            state <= 2'b01; // CALC
                            counter <= n;
                            temp_nf <= 32'h1;
                        end
                    end
                end
                2'b01:
                begin // CALC
                    if (counter == 0)
                    begin
                        state <= 2'b10; // DONE
                        Done <= 1'b1;
                        nf <= temp_nf;
                    end
                    else
                    begin
                        temp_nf <= temp_nf * counter;
                        counter <= counter - 1'b1;
                    end
                end
                2'b10:
                begin // DONE
                    if (~Go)
                        state <= 2'b00; // IDLE
                end
                default: state <= 2'b00;
            endcase
        end
    end

endmodule
