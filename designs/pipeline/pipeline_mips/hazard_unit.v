module hazard_unit(
    input  wire        branchD,
    input wire pc_srcD,
    input  wire [4:0]  rsD,
    input  wire [4:0]  rtD,
    input  wire [4:0]  rsE,
    input  wire [4:0]  rtE,
    input  wire        we_regE,
    input  wire        dm2regE,
    input  wire [4:0]  rf_waE,
    input  wire        we_regM,
    input  wire        dm2regM,
    input  wire [4:0]  rf_waM,
    input  wire        we_regW,
    input  wire [4:0]  rf_waW,
    
    
    output reg         StallF,    // Stall PC Updates
    output reg         StallD,    // Stall IF/ID
    output reg         ForwardAD, 
    output reg         ForwardBD,
    output reg         FlushE,    // Flush ID/EX
    output reg  [1:0]  ForwardAE,
    output reg  [1:0]  ForwardBE,
    output reg         FlushD,
    
    input wire         jrD,
    input wire         jalD,
    input wire         jumpD
   );
    
    wire lwStall;
    wire branchStall;
    wire jrStall;
    
    // Stall logic for LW
    assign lwStall = ((rsD == rtE) || (rtD == rtE)) && dm2regE;
    
    // Stall logic for early branch determination
    assign branchStall = (
        branchD && we_regE && ((rf_waE == rsD) || (rf_waE == rtD))
      ) || (
        branchD && dm2regM && ((rf_waM == rsD) || (rf_waM == rtD))
      );
      
    // Stall logic for JR
    assign jrStall = jrD && (rsD != 0) && ((we_regE && (rf_waE == rsD)) || (dm2regM && (rf_waM == rsD)));
    
    // Drive Stall and Flush for lwStall or BranchStall
    always @(*) begin
      StallF = lwStall || branchStall || jrStall;
      StallD = lwStall || branchStall || jrStall;
      FlushE = lwStall || branchStall || jrStall;
    end
    
    // FlushD Logic for jump instruction
    always @(*) begin
      FlushD = !StallD && (pc_srcD || jrD || jumpD || jalD);
    end
    
    // Forwarding logic for Early Branch Determination
    always @(*) begin
      ForwardAD = (branchD || jrD) && we_regM && (rsD != 0) && (rf_waM == rsD);
      ForwardBD = (branchD) && we_regM && (rtD != 0) && (rf_waM == rtD);
    end
    
    // Data forwarding for Data hazard
    always @(*) begin
      ForwardAE = 2'b00;
      ForwardBE = 2'b00;
      
      // Forwarding from MEM
      if(we_regM && (rsE != 0) && (rf_waM == rsE)) begin
        ForwardAE = 2'b10;
      end
      if(we_regM && (rtE != 0) && (rf_waM == rtE)) begin
        ForwardBE = 2'b10;
      end
      
      // Forwarding from WB
      if(we_regW && (rsE != 0) && (rf_waW == rsE) && !(we_regM && rf_waM == rsE)) begin
        ForwardAE = 2'b01;
      end
      if(we_regW && (rtE != 0) && (rf_waW == rtE) && !(we_regM && rf_waM == rtE)) begin
        ForwardBE = 2'b01;
      end
    end
    
endmodule
