`timescale 1ns/1ps
`include "head.v"
module State(
    input clk,
    input nRST,
    output reg [1:0] stateOut,
    input inEN,
    input resultAC,
    output available,
    output pmfALUEN, // send to pmfALU as EN
    input op,
    output requireCDB
);
    assign available = (requireCDB && resultAC) || stateOut == `sIdle;
    assign pmfAlUEN = available & inEN;
    assign requireCDB = stateOut == `ALUAdd || stateOut == `sMAdd;
    always@(posedge clk or negedge nRST) begin
        if (!nRST) begin
            stateOut <= `sIdle;
        end else begin
            case (stateOut)
                `sIdle : 
                    stateOut <= op == `ALUAdd ? `sAdd : `sInverse;
                `sAdd, `sMAdd : begin
                    if (resultAC) begin
                        if (inEN) begin
                            stateOut <= op == `ALUAdd ? `sAdd : `sInverse;
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
    output reg [31:0] result
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
                `sIdle, `sAdd, `sMAdd :
                    if (EN) begin
                        data1_latch <= dataIn1;
                        data2_latch <= dataIn2;
                    end
                `sInverse :
                    inverseData2_latch <= ~data2_latch;
            endcase
        end
    end

    always@(*) begin
        case (state)
            `sAdd : 
                result = data1_latch + data2_latch;
            `sInverse, `sMAdd : 
                result = data1_latch + inverseData2_latch;
            default :
                result = 32'b0;
        endcase
    end
endmodule
