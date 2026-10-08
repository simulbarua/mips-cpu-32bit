module soc_top(
    input wire clk,
    input wire rst,
    input wire [31:0] gpI1,
    input wire [31:0] gpI2,
    output wire [31:0] gpO1,
    output wire [31:0] gpO2,
    
    // for debug
    input wire  [4:0] ra3,
    output wire [31:0] rd3,
    output wire [31:0] PC
);

    wire MemWrite, WE1, WE2, WEM;

    // Address Decoder signals
    wire [31:0] Address;
    wire [31:0] Instruction;
    wire [31:0] WriteData;
    wire [1:0]  RdSel;
       
    // Read peripherals
    wire [31:0] DMemData;
    wire [31:0] FactData;
    wire [31:0] GPIOData;
    wire [31:0] ReadData;
    

    
    // RD Mux
    assign ReadData = (RdSel == 2'b00 || RdSel == 2'b01) ? DMemData :
                (RdSel == 2'b10) ? FactData :
                (RdSel == 2'b11) ? GPIOData :
                32'h00000000;
                
                
    pipeline_mips pipeline_mips (
        .clk(clk),
        .rst(rst),
        .instrF(Instruction),
        .rd_dmM(ReadData),
        .we_dmM(MemWrite),
        .pc_currentF(PC),
        .wd_dmM(WriteData),
        .alu_outM(Address),
        .ra3(ra3),
        .rd3(rd3)
   );
   
   imem imem(
        .a(PC[7:2]),
        .y(Instruction)
   );
                
   soc_ad soc_ad(
        .A(Address),
        .WE(MemWrite),
        .WE1(WE1),
        .WE2(WE2),
        .WEM(WEM),
        .RdSel(RdSel)
   );
    
    dmem dmem (
        .clk(clk),
        .rst(rst),
        .we(WEM),
        .a(Address[7:2]),
        .d(WriteData),
        .q(DMemData)
    );
    
    fact_top fact_top (
        .clk(clk),
        .rst(rst),
        .A(Address[3:2]),
        .WE(WE1),
        .WD(WriteData[3:0]),
        .RD(FactData)
    );
    
    gpio_top gpio_top (
        .clk(clk),
        .rst(rst),
        .A(Address[3:2]),
        .WE(WE2),
        .WD(WriteData),
        .RD(GPIOData),
        .gpI1(gpI1),
        .gpI2(gpI2),
        .gpO1(gpO1),
        .gpO2(gpO2)
    );

endmodule
