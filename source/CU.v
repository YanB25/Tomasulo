`include "head.v"
`timescale 1ns/1ps
module CU(
    input [5:0] op,
    input [5:0] func,
    output [1:0]ALUop,
    output [1:0]ALUSel,
    output [3:0]ResStationEN,
    input [2:0]isFull,
    output isFullOut,
    output RegDst
);
    always@(*) begin
        case(op) begin
            `opRFormat:
                case(func)
                    `funcAdd, `funcMULU:
                        ALUop = 0;  
                    `funcSUB : ALUop = `ALUSub;
                    `funcAND : ALUop = `ALUAnd;
                    default : ALUop = `ALUOr;
                endcase
            `opMULIU:
                ALUop = 0;
            default:
                ALUop = 1;
        endcase

        if (func == `funcMULU) begin
            ALUSel = `multipleALU;
            ResStationEN = 4'b0010;
        end
        else if (func == `funcDIVU) begin
            ALUSel = `divideALU;
            ResStationEN = 4'b0100;
        end 
        else begin
            ALUSel = `addsubALU;
            ResStationEN = 4'b0001;
        end
    end
    assign isFullOut = isFull[ALUSel];
    assign RegDst = op == `opRFormat ? `FromRd : `FromRt;
endmodule    