`timescale 1ns/1ps
`include "head.v"
module pmfState(
    input clk,
    input nRST,
    output reg [1:0] stateOut,
    input WEN,
    input requireAC,
    output available,
    output pmfALUEN, // send to pmfALU as EN
    input [1:0]op,
    output require
);
    assign available = (require && requireAC) || stateOut == `sIdle;
    assign pmfAlUEN = available && WEN;
    assign require = stateOut == `sPremitiveIns || stateOut == `sMAdd;
    always@(posedge clk or negedge nRST) begin
        if (!nRST) begin
            stateOut <= `sIdle;
        end else begin
            case (stateOut)
                `sIdle : 
                    stateOut <= op == `ALUSub ? `sInverse : `sPremitiveIns;
                `sPremitiveIns, `sMAdd : begin
                    if (requireAC) begin
                        if (WEN) begin
                            stateOut <= op == `ALUSub ? `sInverse : `sPremitiveIns;
                        end else begin
                            stateOut <= `sIdle;
                        end
                    end
                end
                `sInverse:
                    stateOut <= `sMAdd;
            endcase
        end
    end
endmodule

module pmfALU(
    input clk,
    input nRST,
    input EN, // linked from State::pmfALUEN
    input [31:0] dataIn1,
    input [31:0] dataIn2,
    input [1:0] state,
    input [1:0]op,
    output reg [31:0] result,
    input [3:0] labelIn,
    output reg [3:0] labelOut
);
    reg [31:0] data1_latch;
    reg [31:0] data2_latch;
    reg [31:0] inverseData2_latch;
    always@(posedge clk or negedge nRST) begin
        if (!nRST) begin
            data1_latch <= 32'b0;
            data2_latch <= 32'b0;
            inverseData2_latch <= 31'b0;
        end else begin
            case (state)
                `sIdle, `sPremitiveIns, `sMAdd :
                    if (EN) begin
                        data1_latch <= dataIn1;
                        data2_latch <= dataIn2;
                        labelOut <= labelIn;
                    end
                `sInverse :
                    inverseData2_latch <= ~data2_latch;
            endcase
        end
    end

    always@(*) begin
        case (op)
            `ALUAdd : 
                result = data1_latch + data2_latch;
            `ALUSub : 
                result = data1_latch + inverseData2_latch;
            `ALUAnd :
                result = data1_latch & data2_latch;
            `ALUOr:
                result = data1_latch & data2_latch;
            default:
                result = 32'b0;
        endcase
    end
endmodule
