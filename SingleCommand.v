module RISCV ();
reg clk;
reg rst;
wire PCSrc,zero,MemWrite,ALUSrc,RegWrite;
wire [2:0] ALUControl;
wire [1:0] ImmSrc,ResultSrc;
wire [31:0] PCin;
wire [31:0] PCout,DMEMout;
wire [31:0] Instr,ALUSrcOut,ALUResult;
wire [31:0] PCOutPlus,PCOutTarget;
wire [31:0] ImmExt,Result,RA,RB;
reg [31:0] mem [0:1023];

PC pc(
    .clk(clk),
    .rst(rst),
    .PCin(PCin),
    .PCout(PCout)
);
IMEM imem(
    .PCin(PCout),
    .Instruction(Instr)
);
PCPlus pcplus(
    .PCin(PCout),
    .PCout(PCOutPlus)
);
mux2to1 muxPC (
    .sel(PCSrc),
    .in0(PCOutPlus),
    .in1(PCOutTarget),
    .out(PCin)
);
PCTarget pctarget(
    .PCin(PCout),
    .offset(ImmExt),
    .PCout(PCOutTarget)
);
ControlUnit controlUnit(
    .zero(zero),
    .op(Instr[6:0]),
    .funct3(Instr[14:12]),
    .funct7b5(Instr[30]),
    .PCSrc(PCSrc),
    .ResultSrc(ResultSrc), 
    .MemWrite(MemWrite),
    .ALUControl(ALUControl),
    .ALUSrc(ALUSrc),
    .ImmSrc(ImmSrc),
    .RegWrite(RegWrite)
);

ImmGen immGen(
    .ImmSrc(ImmSrc),
    .Instr(Instr[31:7]),
    .ImmExt(ImmExt)
);

Register register(
    .clk(clk),
    .WD(Result),
    .WE(RegWrite),
    .A(Instr[19:15]),
    .B(Instr[24:20]),
    .D(Instr[11:7]),
    .RA(RA),
    .RB(RB)
);
mux2to1 muxALU (
    .sel(ALUSrc),
    .in0(RB),
    .in1(ImmExt),
    .out(ALUSrcOut)
);

ALU alu (
    .A(RA),
    .B(ALUSrcOut),
    .ALUControl(ALUControl),
    .ALUOut(ALUResult),
    .zero(zero)
);

DMEM dmem (
    .clk(clk),
    .WE(MemWrite),
    .addr(ALUResult),
    .WD(RB),
    .RD(DMEMout)
);

mux3to1 m31 (
    .sel(ResultSrc),
    .in0(ALUResult),
    .in1(DMEMout),
    .in2(PCOutPlus),
    .out(Result)
);
initial begin
    $readmemh("./testcong.txt",mem);
    //$writememh("DMEM.txt",content); 
    clk=0;rst=1;
   #100 clk=~clk;rst=1;
   #100 clk=~clk;rst=0;
   forever #100 clk=~clk;
end
endmodule