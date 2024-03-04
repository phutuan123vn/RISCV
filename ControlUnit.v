module MainDecoder (
    input [6:0] op,
    output reg Branch,
    output reg [1:0]ResultSrc,
    output reg MemWrite,
    output reg AluSrc,
    output reg [1:0] ImmSrc,
    output reg RegWrite,
    output reg [1:0] ALUOp,
    output reg Jump
);
always @(op) begin
    case (op)
        7'b0000011://lw
            begin
            RegWrite = 1; ImmSrc = 2'b00; AluSrc = 1; MemWrite = 0; ResultSrc = 1; Branch = 0; ALUOp = 2'b00; Jump = 0;
            end
        7'b0100011://sw
            begin
            RegWrite = 0; ImmSrc = 2'b01; AluSrc = 1; MemWrite = 1; ResultSrc = 'x; Branch = 0; ALUOp = 2'b00; Jump = 0;
            end
        7'b0110011://R type
            begin
            RegWrite = 1; ImmSrc = 2'bxx; AluSrc = 0; MemWrite = 0; ResultSrc = 0; Branch = 0; ALUOp = 2'b10; Jump = 0;
            end
        7'b1100011://branch
            begin
            RegWrite = 0; ImmSrc = 2'b10; AluSrc = 0; MemWrite = 0; ResultSrc = 'x; Branch = 1; ALUOp = 2'b01; Jump = 0;
            end
        7'b0010011://I type
            begin
            RegWrite = 1; ImmSrc = 2'b00; AluSrc = 1; MemWrite = 0; ResultSrc = 0; Branch = 0; ALUOp = 2'b10; Jump = 0;
            end
        7'b1101111://jal
            begin
            RegWrite = 1; ImmSrc = 2'b11; AluSrc = 'x; MemWrite = 0; ResultSrc = 2'b10; Branch = 0; ALUOp = 2'bxx; Jump = 1;
            end
        default: begin
            RegWrite = 'z; ImmSrc = 2'bz; AluSrc = 'z; MemWrite = 'z; ResultSrc = 'z; Branch = 'z; ALUOp = 2'bz; Jump = 'z;
        end
    endcase
end 
endmodule

module ALUDecoder (
    input op5,
    input [2:0] funct3,
    input funct7b5,
    input [1:0]ALUOp,
    output reg [2:0] ALUControl
);
always @(*) begin
    casex ({ALUOp,funct3,op5,funct7b5})
        {2'b00,{5{1'bx}}}: ALUControl = 3'b000;
        {2'b01,{5{1'bx}}}: ALUControl = 3'b001;
        {2'b10,3'b000,2'b00},
        {2'b10,3'b000,2'b01},
      	{2'b10,3'b000,2'b10}: ALUControl = 3'b000; // ALU OUT
        {2'b10,3'b000,2'b11}: ALUControl = 3'b001;
        {2'b10,3'b010,2'bxx}: ALUControl = 3'b101;
        {2'b10,3'b110,2'bxx}: ALUControl = 3'b011;
        {2'b10,3'b111,2'bxx}: ALUControl = 3'b010;
        default: ALUControl = 3'bz;
    endcase
end
endmodule

module ControlUnit (
    input zero,
    input [6:0] op,
    input [2:0] funct3,
    input funct7b5,
    output PCSrc,
    output [1:0] ResultSrc,
    output MemWrite,
    output [2:0] ALUControl,
    output ALUSrc,
    output [1:0] ImmSrc,
    output RegWrite
);
wire [1:0] ALUOp;
wire Branch;
wire Jump;
MainDecoder mainDecoder(
    .op(op),
    .Branch(Branch),
    .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
    .AluSrc(ALUSrc),
    .ImmSrc(ImmSrc),
    .RegWrite(RegWrite),
    .ALUOp(ALUOp),
    .Jump(Jump)
);
ALUDecoder aluDecoder(
    .op5(op[5]),
    .funct3(funct3),
    .funct7b5(funct7b5),
    .ALUOp(ALUOp),
    .ALUControl(ALUControl)
);
assign PCSrc = (Branch & zero) | Jump;  
endmodule

///////*PIPELINE*////////////////

module ControlUnit_Pipeline (
    input [6:0] op,
    input [2:0] funct3,
    input funct7b5,
    output RegWriteD,
    output [1:0] ResultSrcD,
    output MemWriteD,
    output JumpD,
    output BranchD,
    output [2:0] ALUControlD,
    output ALUSrcD,
    output [1:0] ImmSrcD
);
wire [1:0] ALUOp;
MainDecoder mainDecoder(
    .op(op),
    .Branch(BranchD),
    .ResultSrc(ResultSrcD),
    .MemWrite(MemWriteD),
    .AluSrc(ALUSrcD),
    .ImmSrc(ImmSrcD),
    .RegWrite(RegWriteD),
    .ALUOp(ALUOp),
    .Jump(JumpD)
);
ALUDecoder aluDecoder(
    .op5(op[5]),
    .funct3(funct3),
    .funct7b5(funct7b5),
    .ALUOp(ALUOp),
    .ALUControl(ALUControlD)
);
endmodule