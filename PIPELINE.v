module RISCV_PIPE;
reg clk;
reg rst;
wire [31:0] PCin,PCTargetE,PCP4,PC_D,PCP4_D,PCP4_M,PCP4_WB;
wire PCSrcE,StallF,StallD,FlushD,FlushE,RegWriteM;
wire [31:0] Instr,InstrD,ResultW,RA_D,RB_D,ImmExt_D,SrcAE,SrcBE;
wire RegWriteD,MemWriteD,JumpD,BranchD;
wire [4:0] D_WB,D_M,A_E,B_E,D_E;
wire ALUSrcD,RegWriteW;
wire [31:0] RA_E,RB_E,PC_E,ImmExt_E,PCP4_E;
wire RegWriteE,MemWriteE,JumpE,BranchE,ALUSrcE,MemWriteM;
wire [1:0] ResultSrcE,ResultSrcM,ResultSrcW,ResultSrcD,ImmSrcD;
wire [2:0] ALUControlD,ALUControlE;
wire [31:0] ALUResult_E,ALUResult_M,ALUResult_WB,WriteData_E,WriteData_M;
wire [31:0] DMEMDataIn,DMEMDataOut;
wire [1:0] ForwardA,ForwardB;
wire zero;
wire [31:0] PCOut;

assign PCSrcE = (BranchE & zero) | JumpD;

mux2to1 muxPC (
    .sel(PCSrcE),
    .in0(PCP4),
    .in1(PCTargetE),
    .out(PCin)
);

PC_Pipe pc_pipe(
    .clk(clk),
    .PCIn(PCin),
    .rst(rst),
    .EN(StallF),
    .PCOut(PCOut)
);

IMEM imem(
    .PCin(PCOut),
    .Instruction(Instr)
);

PCPlus pcplus(
    .PCin(PCOut),
    .PCout(PCP4)
);

FetchDecode fetchdecode (
    .clk(clk),
    .clr_FlushD(FlushD),
    .En_StallD(StallD),
    .rst(rst),
    .PC(PCOut),
    .InstrIn(Instr),
    .PCP4(PCP4),
    /////// outputs ///////
    .InstrD(InstrD),
    .PC_D(PC_D),
    .PCP4_D(PCP4_D)
);

ControlUnit_Pipeline control (
    .op(InstrD[6:0]),
    .funct3(InstrD[14:12]),
    .funct7b5(InstrD[30]),
    /////// outputs ///////
    .RegWriteD(RegWriteD),
    .ResultSrcD(ResultSrcD),
    .MemWriteD(MemWriteD),
    .JumpD(JumpD),
    .BranchD(BranchD),
    .ALUControlD(ALUControlD),
    .ALUSrcD(ALUSrcD),
    .ImmSrcD(ImmSrcD)
);

Register_Pipe register (
    .clk(clk),
    .A(InstrD[19:15]),
    .B(InstrD[24:20]),
    .D(D_WB),
    .WD(ResultW),
    .WE(RegWriteW),
    .RA(RA_D),
    .RB(RB_D)
);

ImmGen immgen (
    .ImmSrc(ImmSrcD),
    .Instr(InstrD[31:7]),
    .ImmExt(ImmExt_D)
);

DecodeExecute decodeexecute (
    .clk(clk),
    .clr_FlushE(FlushE),
    .RA_D(RA_D),
    .RB_D(RB_D),
    .PC_D(PC_D),
    .A_D(InstrD[19:15]),
    .B_D(InstrD[24:20]),
    .D_D(InstrD[11:7]),
    .ImmExt_D(ImmExt_D),
    .PCP4_D(PCP4_D),
    //////// outputs/////////
    .RA_E(RA_E),
    .RB_E(RB_E),
    .PC_E(PC_E),
    .A_E(A_E),
    .B_E(B_E),
    .D_E(D_E),
    .ImmExt_E(ImmExt_E),
    .PCP4_E(PCP4_E)
);

Control_DE control_de (
    .clk(clk),
    .RegWriteD(RegWriteD),
    .ResultSrcD(ResultSrcD),
    .MemWriteD(MemWriteD),
    .JumpD(JumpD),
    .BranchD(BranchD),
    .ALUControlD(ALUControlD),
    .ALUSrcD(ALUSrcD),
    /////// outputs ///////
    .RegWriteE(RegWriteE),
    .MemWriteE(MemWriteE),
    .JumpE(JumpE),
    .BranchE(BranchE),
    .ALUControlE(ALUControlE),
    .ALUSrcE(ALUSrcE),
    .ResultSrcE(ResultSrcE)
);

Control_EM control_em (
    .clk(clk),
    .RegWriteE(RegWriteE),
    .ResultSrcE(ResultSrcE),
    .MemWriteE(MemWriteE),
    //// outputs ////
    .RegWriteM(RegWriteM),
    .ResultSrcM(ResultSrcM),
    .MemWriteM(MemWriteM)
);

Control_MW control_mw (
    .clk(clk),
    .RegWriteM(RegWriteM),
    .ResultSrcM(ResultSrcM),
    /// outputs ///
    .RegWriteW(RegWriteW),
    .ResultSrcW(ResultSrcW)
);

ExecuteMemory executememory (
    .clk(clk),
    .ALUResult_E(ALUResult_E),
    .WriteData_E(WriteData_E),
    .D_E(D_E),
    .PCP4_E(PCP4_E),
    ///// Outputs /////
    .ALUResult_M(ALUResult_M),
    .WriteData_M(WriteData_M),
    .D_M(D_M),
    .PCP4_M(PCP4_M)
);

MemoryWriteback mw (
    .clk(clk),
    .ALUResult_M(ALUResult_M),
    .DMEMDataIn(DMEMDataIn),
    .D_M(D_M),
    .PCP4_M(PCP4_M),
    /////// Outputs ///////
    .ALUResult_WB(ALUResult_WB),
    .DMEMDataOut(DMEMDataOut),
    .D_WB(D_WB),
    .PCP4_WB(PCP4_WB)
);

mux3to1 muxSrcA (
    .sel(ForwardA),
    .in0(RA_E),
    .in1(ResultW),
    .in2(ALUResult_M),
    .out(SrcAE)
);

mux3to1 muxSrcB (
    .sel(ForwardB),
    .in0(RB_E),
    .in1(ResultW),
    .in2(ALUResult_M),
    .out(WriteData_E)
);

mux2to1 muxALU (
    .sel(ALUSrcE),
    .in0(WriteData_E),
    .in1(ImmExt_E),
    .out(SrcBE)
);

ALU alu(
    .A(SrcAE),
    .B(SrcBE),
    .ALUControl(ALUControlE),
    .ALUOut(ALUResult_E),
    .zero(zero)
);

PCTarget pctarget(
    .PCin(PC_E),
    .offset(ImmExt_E),
    .PCout(PCTargetE)
);

DMEM_Pipe dmem_pipe (
    .clk(clk),
    .WE(MemWriteM),
    .addr(ALUResult_M),
    .WD(WriteData_M),
    .RD(DMEMDataIn)
);

mux3to1 muxResult(
    .sel(ResultSrcW),
    .in0(ALUResult_WB),
    .in1(DMEMDataOut),
    .in2(PCP4_WB),
    .out(ResultW)
);

HazardUnit hazardunit (
    .A_E(A_E),
    .B_E(B_E),
    .D_M(D_M),
    .RegWriteM(RegWriteM),
    .D_E(D_E),
    .D_WB(D_WB),
    .RegWriteW(RegWriteW),
    .ResultSrcE_0(ResultSrcE[0]),
    .PCSrcE(PCSrcE),
    //// outputs ////
    .ForwardA(ForwardA),
    .ForwardB(ForwardB),
    .StallF(StallF),
    .StallD(StallD),
    .FlushD(FlushD),
    .FlushE(FlushE)
);
initial begin
    // $readmemh("./testcong.txt",mem);
    //$writememh("DMEM.txt",content); 
    clk=0;rst=1;
   #100 clk=~clk;rst=1;
   #100 clk=~clk;rst=0;
   forever #100 clk=~clk;
end

endmodule