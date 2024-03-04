module Forwarding (
    input [4:0] A_E,
    input [4:0] B_E,
    input [4:0] D_M,
    input RegWriteM,
    input [4:0] D_WB,
    input RegWriteW,
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB,
);
// reg [4:0] oldA_E;
// reg [4:0] oldB_E;
always @(*) begin
    if ((D_M == A_E) && (RegWriteM) && (A_E != 0)) begin
        ForwardA = 2'b10;
    end else if ((D_WB == A_E) && (RegWriteW) && (A_E != 0)) begin
        ForwardA = 2'b01;
    end else begin
        ForwardA = 2'b00;
    end
    if ((D_M == B_E) && (RegWriteM) && (B_E != 0)) begin
        ForwardB = 2'b10;
    end else if ((D_WB == B_E) && (RegWriteW) && (B_E != 0)) begin
        ForwardB = 2'b01;
    end else begin
        ForwardB = 2'b00;
    end
end
endmodule

/////////////////////////* Stall *//////////////////////////////

module Stall (
    input ResultSrcE_0,
    input [4:0] A_E,
    input [4:0] B_E,
    input [4:0] D_E,
    output lwStall
);
assign lwStall = ResultSrcE_0 & ((A_E == D_E) | (B_E == D_E));    
endmodule


module HazardUnit (
    input [4:0] A_E,
    input [4:0] B_E,
    input [4:0] D_M,
    input RegWriteM,
    input [4:0] D_E,
    input [4:0] D_WB,
    input RegWriteW,
    input ResultSrcE_0,
    input PCSrcE,
    output [1:0] ForwardA,
    output [1:0] ForwardB,
    output reg StallF,
    output reg StallD,
    output reg FlushD,
    output reg FlushE
);
wire lwStall;
Forwarding forward(
    .A_E(A_E),
    .B_E(B_E),
    .D_M(D_M),
    .RegWriteM(RegWriteM),
    .D_WB(D_WB),
    .RegWriteW(RegWriteW),
    .ForwardA(ForwardA),
    .ForwardB(ForwardB)
);
Stall stall(
    .ResultSrcE_0(ResultSrcE_0),
    .A_E(A_E),
    .B_E(B_E),
    .D_E(D_E),
    .lwStall(lwStall)
);
assign StallF = lwStall;
assign StallD = lwStall;
assign FlushD = PCSrcE;
assign FlushE = PCSrcE | lwStall;

endmodule