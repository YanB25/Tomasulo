//TODO NOT FINISHED
`timescale 1ns/1ps
`include "head.v"
module dfState(
    input clk,
    input nRST,
    output reg stateOut, // to ALU
    output reg [5:0]cnt,
    input WEN,
    input requireAC,
    output available,
    output dfALUEN, // determine whether mdfALU should work
    output require,
    output keepLooping // send to dfALU
);
    assign available = (require && requireAC) || stateOut == `sIdle;
    assign mdfALUEN = available && WEN;
    assign require = stateOut == `sWorking && cnt[5];
    always@(posedge clk or negedge nRST) begin
        if (!nRST) begin
            stateOut <= `sIdle;
            cnt <= 0;
        end else begin
            case(stateOut)
                `sIdle:
                    if (WEN)
                        stateOut <= `sWorking;
                `sWorking:
                    if (cnt[5]) begin
                        if (requireAC) begin
                            stateOut <= WEN ? `sWorking : `sIdle;
                            cnt <= 0;
                        end
                    end else begin
                        cnt <= cnt + 1;
                    end
            endcase
        end
    end
endmodule
