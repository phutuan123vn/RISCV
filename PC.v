module PC (
    input clk,
    input rst,
    input [31:0] PCin,
    output reg [31:0] PCout
);
always @(posedge clk) begin
    if (rst) #1 PCout <= 32'b0;
    else #1 PCout <= PCin;
end
endmodule

module PCPlus (
    input [31:0] PCin,
    output [31:0] PCout
);
assign PCout = PCin + 4;
endmodule

module PCTarget (
    input [31:0] PCin,
    input [31:0] offset,
    output [31:0] PCout
);
assign PCout = PCin + offset;
    
endmodule

module PC_Pipe (
    input clk,
    input [31:0] PCIn,
    input rst,
    input EN,
    output reg [31:0] PCOut
);
always @(posedge clk or negedge clk) begin
    if (rst) #1 PCOut <= 32'b0;
    else if (~EN) #1 PCOut <= PCIn;
end 
endmodule