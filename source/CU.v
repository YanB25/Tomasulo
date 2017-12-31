`include "head.v"
`timescale ins/1ps
module CU(
    input [5:0] op,
    input [5:0] func,
    output [1:0]ALUop,
    output [1:0]ALUSel,
    input [2:0]isFull,
    output isFullOut
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

        if (func == `funcMULU)
            ALUSel = `multipleALU;
        else if (func == `funcDIVU)
            ALUSel = `divideALU;
        else ALUSel = `addsubALU;
    end
    assign isFullOut = isFull[ALUSel];
endmodule    