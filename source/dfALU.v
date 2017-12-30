`timescale 1ns/1ps
`include "head.v"
module dfState(
    input clk,
    input nRST,
    output reg stateOut, // to ALU
    output reg [5:0]cnt,
    input inEN,
    input resultAC,
    output available,
    output dfALUEN // determine whether mdfALU should work
);
    assign available = ((stateOut == `sWorking) && cnt[5]) || stateOut == `sIdle;
    assign mdfALUEN = available && inEN;
    always@(posedge clk or negedge nRST) begin
        if (!nRST) begin
            stateOut <= `sIdle;
            cnt <= 0;
        end else begin
            case(stateOut)
                `sIdle:
                    if (inEN)
                        stateOut <= `sWorking;
                `sWorking:
                    if (cnt[5] && resultAC && !inEN) begin
                        stateOut <= `sIdle;
                        cnt <= 0;
                    end else begin
                        cnt <= cnt + 1;
                    end
            endcase
        end
    end
endmodule