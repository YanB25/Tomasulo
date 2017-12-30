//TODO NOT FINISHED
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
    output dfALUEN, // determine whether mdfALU should work
    output requireCDB,
    output keepLooping // send to dfALU
);
    assign available = (requireCDB && resultAC) || stateOut == `sIdle;
    assign mdfALUEN = available && inEN;
    assign requireCDB = stateOut == `sWorking && cnt[5];
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
                    if (cnt[5]) begin
                        if (resultAC) begin
                            stateOut <= inEN ? `sWorking : `sIdle;
                            cnt <= 0;
                        end
                    end else begin
                        cnt <= cnt + 1;
                    end
            endcase
        end
    end
endmodule
