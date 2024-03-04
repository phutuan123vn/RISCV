module Register (
    input clk,
    input [4:0] A,
    input [4:0] B,
    input [4:0] D,
    input [31:0] WD,
    input WE,
    output [31:0] RA,
    output [31:0] RB
);
integer i;
reg [31:0] mem[0:31];
initial begin
    for (i = 0;i <=31 ; i = i+1 ) begin
        mem[i] = 32'b0;
    end
end
always @(posedge clk) begin
    if (WE && (D!=0)) mem[D] <= WD;
end
assign RA = (A!=0) ? mem[A] : 32'b0;
assign RB = (B!=0) ? mem[B] : 32'b0;
endmodule

module DMEM (
    input clk,
    input WE,
    input [31:0] addr,
    input [31:0] WD,
    output [31:0] RD);
integer i;
reg [31:0] DataMem [0:1023];
initial begin
    for (i = 0; i <= 1023; i = i + 1) begin
        DataMem[i] = 32'b0;
    end
end

always @(posedge clk) begin
    if (WE) DataMem[addr] <= WD;
end
assign RD = DataMem[addr];
endmodule

///////////////////////*PIPELINE*/////////////////////////


module Register_Pipe (
    input clk,
    input [4:0] A,
    input [4:0] B,
    input [4:0] D,
    input [31:0] WD,
    input WE,
    output [31:0] RA,
    output [31:0] RB
);
integer i;
reg [31:0] mem[0:31];
initial begin
    for (i = 0;i <=31 ; i = i+1 ) begin
        mem[i] = 32'b0;
    end
end
always @(posedge clk or negedge clk) begin
    if (WE && (D!=0)) mem[D] <= WD;
end
assign RA = (A!=0) ? mem[A] : 32'b0;
assign RB = (B!=0) ? mem[B] : 32'b0;
endmodule



module DMEM_Pipe (
    input clk,
    input WE,
    input [31:0] addr,
    input [31:0] WD,
    output [31:0] RD);
integer i;
reg [31:0] DataMem [0:1023];
initial begin
    for (i = 0; i <= 1023; i = i + 1) begin
        DataMem[i] = 32'b0;
    end
end

always @(posedge clk or negedge clk) begin
    if (WE) DataMem[addr] <= WD;
end
assign RD = DataMem[addr];
endmodule