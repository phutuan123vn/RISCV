///////////////// Fetch/Decode MODULE ///////////////////////
module FetchDecode (
    input clk,
    input clr_FlushD,
    input En_StallD,
    input rst,
    input [31:0] PC,  // Program Counter
    input [31:0] InstrIn,  // Instruction input
    input [31:0] PCP4,  // PC + 4
    output reg [31:0] InstrD,  // Instruction output
    output reg [31:0] PC_D, // Program Counter output
    output reg [31:0] PCP4_D  // PC + 4 output to Decode
);
always @(posedge clk or negedge clk or clr_FlushD) begin
    // if (clr_FlushD) begin
    //     InstrOut <= InstrIn;
    //     PC_D <= PC;
    //     PCP4_D <= PCP4;
    // end
    if (~En_StallD or rst) begin
        InstrD <= InstrIn;
        PC_D <= PC;
        PCP4_D <= PCP4;
    end
    if (clr_FlushD) begin
        InstrD <= InstrIn;
        PC_D <= PC;
        PCP4_D <= PCP4;
    end

end
endmodule

///////////////////// DECODE/Execute MODULE ///////////////////////

module DecodeExecute (
    input clk,
    input clr_FlushE,
    input [31:0] RA_D,
    input [31:0] RB_D,
    input [31:0] PC_D,  // Program Counter Decoded input by Program Counter Decoder
    input [4:0] A_D, // Register A 19:15
    input [4:0] B_D, // Register B 24:20
    input [4:0] D_D, // Register D 11:7
    input [31:0] ImmExt_D,  // Immediate Decode
    input [31:0] PCP4_D, // PC + 4 input from Fetch
    output reg [31:0] RA_E,
    output reg [31:0] RB_E,
    output reg [31:0] PC_E,  // Program Counter output
    output reg [4:0] A_E, // Register A 19:15 Execute
    output reg [4:0] B_E, // Register B 24:20 Execute
    output reg [4:0] D_E, // Register D 11:7 Execute
    output reg [31:0] ImmExt_E,  // Immediate output
    output reg [31:0] PCP4_E  // PC + 4 output to Execute
);
always @(posedge clk or negedge clk) begin
    if (~clr_FlushE) begin
        RA_E <= RA_D;
        RB_E <= RB_D;
        PC_E <= PC_D;
        A_E <= A_D;
        B_E <= B_D;
        D_E <= D_D;
        ImmExt_E <= ImmExt_D;
        PCP4_E <= PCP4_D;
    end
    if (clr_FlushE) begin
        RA_E <= 0;
        RB_E <= 0;
        PC_E <= 0;
        A_E <= 0;
        B_E <= 0;
        D_E <= 0;
        ImmExt_E <= 0;
        PCP4_E <= 0;
    end
end

endmodule

module Control_DE (
    input clk,
    input RegWriteD,
    input [1:0] ResultSrcD,
    input MemWriteD,
    input JumpD,
    input BranchD,
    input [2:0] ALUControlD,
    input ALUSrcD,
    output reg RegWriteE,
    output reg [1:0] ResultSrcE,
    output reg MemWriteE,
    output reg JumpE,
    output reg BranchE,
    output reg [2:0] ALUControlE,
    output reg ALUSrcE);
always @(posedge clk or negedge clk) begin
   RegWriteE <= RegWriteD;
   ResultSrcE <= ResultSrcD;
    MemWriteE <= MemWriteD;
    JumpE <= JumpD;
    BranchE <= BranchD;
    ALUControlE <= ALUControlD;
    ALUSrcE <= ALUSrcD;
end
endmodule

///////////////////// EXECUTE/Memory MODULE ///////////////////////
module ExecuteMemory (
    input clk,
    input [31:0] ALUResult_E,
    input [31:0] WriteData_E,
    input [4:0] D_E,
    input [31:0] PCP4_E,
    output reg [31:0] ALUResult_M,
    output reg [31:0] WriteData_M,
    output reg [4:0] D_M,
    output reg [31:0] PCP4_M
);
always @(posedge clk or negedge clk) begin
    ALUResult_M <= ALUResult_E;
    WriteData_M <= WriteData_E;
    D_M <= D_E;
    PCP4_M <= PCP4_E;
end
endmodule

module Control_EM (
    input clk,
    input RegWriteE,
    input [1:0] ResultSrcE,
    input MemWriteE,
    output reg RegWriteM,
    output reg [1:0] ResultSrcM,
    output reg MemWriteM
);
always @(posedge clk or negedge clk) begin
    RegWriteM <= RegWriteE;
    ResultSrcM <= ResultSrcE;
    MemWriteM <= MemWriteE;
end
    
endmodule

/////////////////////////* Memory/Writeback Module *//////////////////////////////
module MemoryWriteback (
    input clk,
    input [31:0] ALUResult_M,
    input [31:0] DMEMDataIn,
    input [4:0] D_M,
    input [31:0] PCP4_M,
    output reg [31:0] ALUResult_WB,
    output reg [31:0] DMEMDataOut,
    output reg [4:0] D_WB,
    output reg [31:0] PCP4_WB
);
always @(posedge clk or negedge clk) begin
    ALUResult_WB <= ALUResult_M;
    DMEMDataOut <= DMEMDataIn;
    D_WB <= D_M;
    PCP4_WB <= PCP4_M;
end
endmodule

module Control_MW (
    input clk,
    input RegWriteM,
    input [1:0] ResultSrcM,
    output reg RegWriteW,
    output reg [1:0] ResultSrcW
);
always @(posedge clk or negedge clk) begin
    RegWriteW <= RegWriteM;
    ResultSrcW <= ResultSrcM;
end
endmodule