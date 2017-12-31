`timescale 1ns/1ps
`include "../source/head.v"
module top_tb;
    reg clk = 0;
    reg nRST = 1;
    initial begin
        #1;
        nRST = 0;
        #2;
        nRST = 1;
    end
    always begin
        #5;
        clk = ~clk;
    end
    top top_(
        .clk,
        .nRST
    );
endmodule