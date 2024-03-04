module IMEM (
    input [31:0] PCin,
    output [31:0] Instruction
);
reg [31:0] mem[0:1023]; //Instructions are stored in a memory array
initial begin
    $readmemh("testbench.txt", mem);
end
assign Instruction = mem[PCin[31:2]];
endmodule