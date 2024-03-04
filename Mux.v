module mux2to1 (
    input sel,
    input [31:0] in0,
    input [31:0] in1,
    output [31:0] out
);
assign out = (sel) ? in1 : in0;
endmodule

module mux3to1 (
    input [1:0]sel,
    input [31:0] in0,
    input [31:0] in1,
    input [31:0] in2,
    output [31:0] out
);
assign out = (sel[1]) ? in2 : (sel[0]) ? in1 : in0;
endmodule