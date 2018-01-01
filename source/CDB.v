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
        else if (requires[0])
            accepts = 4'b0001;
        else
            accepts = 4'b0000;
    end
endmodule

module CDB(
    input [31:0] data0,
    input [3:0] label0,
    input [31:0] data1,
    input [3:0] label1,
    input [31:0] data2,
    input [3:0] label2,
    input [31:0] data3,
    input [3:0] label3,
    input [3:0] sel,
    output reg[31:0] dataOut,
    output reg[3:0] labelOut,
    output EN
);
    always@(*) begin
        if (sel[0]) begin
            dataOut = data0;
            labelOut = label0;
        end else if (sel[1]) begin
            dataOut = data1;
            labelOut = label1;
        end else if (sel[2]) begin
            dataOut = data2;
            labelOut = label2;
        end else begin
            dataOut = data3;
            labelOut = label3;
        end
    end
    assign EN = | sel;
endmodule