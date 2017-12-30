`timescale 1ns/1ps
`include "head.v"
module CDBHelper(
    input [3:0] requires,
    output reg [3:0] accepts
);
    always@(*) begin
        if (requires[3])
            accepts = 4'b1000;
        else if (requires[2])
            accepts = 4'b0100;
        else if (requires[1])
            accepts = 4'b0010;
        else
            accepts = 4'b0001;
    end
endmodule

module CDB(
    input [31:0] data0,
    input [4:0] label0,
    input [31:0] data1,
    input [4:0] label1,
    input [31:0] data2,
    input [4:0] label2,
    input [31:0] data3,
    input [4:0] label3,
    input [3:0] sel,
    output [31:0] dataOut,
    output [4:0] labelOut,
    output EN
);
    assign dataOut = (sel[0] & data0) |
        (sel[1] & data1) |
        (sel[2] & data2) |
        (sel[3] & data3);
    assign labelOut = (sel[0] & label0) |
        (sel[1] & data1) |
        (sel[2] &data2) |
        (sel[3] &data3);

    assign EN = &sel;
endmodule