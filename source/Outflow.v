`include "head.v"
`timescale 1ns / 1ps
module Outflow(
    output [4:0] readAddr1,
    output [4:0] readAddr2,
    input [4:0] labelIn1,
    input [4:0] labelIn2,
    input [31:0] dataIn1,
    input [31:0] dataIn2,

    input [5:0] op,
    input [5:0] func,
    input [4:0] sftamt,
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] rd,
    input [15:0] immd16,
    input [25:0] immd26,
    output [5:0] selALU,
    output [5:0] op,
    output [4:0] label1,
    output [4:0] label2,
    output [31:0] value1,
    output [31:0] value2,
    output [4:0] target,
    output [31:0] Imm,
    );

    assign readAddr1 = rs;
    assign readAddr2 = rt;

    always@(*) begin
        label1 <= labelIn1;
        value1 <= dataIn1;
        label2 <= labelIn2;
        value2 <= dataIn2;


    end

endmodule