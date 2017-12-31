`include "head.v"
`timescale 1ns / 1ps
module Outflow(
    output [4:0] readAddr1,
    output [4:0] readAddr2,
    input [3:0] labelIn1,
    input [3:0] labelIn2,
    input [31:0] dataIn1,
    input [31:0] dataIn2,

    input [31:0] ins,
    output [5:0] selALU,
    output  op,
    output [3:0] label1,
    output [3:0] label2,
    output [31:0] value1,
    output [31:0] value2,
    output [4:0] target,
    output [31:0] Imm,
    );
    assign op = ins[31:26];
    assign func = ins[5:0];
    assign sftamt = ins[10:6];
    assign rs = ins[25:21];
    assign rt = ins[20:16];
    assign rd = ins[15:11];
    assign immd16 = ins[15:0];
    assign immd26 = ins[25:0];

    assign readAddr1 = rs;
    assign readAddr2 = rt;

    always@(*) begin
        label1 = labelIn1;
        value1 = dataIn1;
        label2 = labelIn2;
        value2 = dataIn2;


    end

endmodule