module ALU (
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALUControl,
    output reg [31:0] ALUOut,
    output zero
);
always @(*) begin
    case (ALUControl)
        3'b000: ALUOut = A + B;
        3'b001: ALUOut = A - B;
        3'b010: ALUOut = A & B;
        3'b011: ALUOut = A | B;
        3'b101: ALUOut = A < B ? 1'b1 : 1'b0;
        default: ALUOut = 32'bz;
    endcase
end
assign zero = (A=B) ? 1'b1 : 1'b0;
endmodule