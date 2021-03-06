`timescale 1ns/1ps
`include "head.v"
module mfState(
    input clk,
    input nRST,
    output reg [2:0] stateOut, // to ALU
    input WEN,
    input requireAC,
    output available,
    output mfALUEN, // determine whether mdfALU should work
    input [1:0] op, // do nothing
    output require
);
    assign available = (require && requireAC) || stateOut == `sIdle;
    assign mfALUEN = available && WEN;
    assign require = stateOut == `sMulAnswer;
    always@(posedge clk or negedge nRST) begin
        if (!nRST) begin
            stateOut <= `sIdle;
        end else begin
            case(stateOut)
                `sMulAnswer:
                    if (requireAC) begin
                        stateOut <= WEN ? `sMul32 : `sIdle;
                    end
                `sIdle:
                    if (WEN)
                        stateOut <= `sMul32;
                default:
                    stateOut <= stateOut + 1;
            endcase
        end
    end
endmodule

module mfALU(
    input clk,
    input nRST,
    input EN, // linked from state::mfALUEN
    input [31:0] dataIn1,
    input [31:0] dataIn2,
    input [2:0] state,
    input [3:0] labelIn,
    output reg [31:0] result,
    output reg [3:0] labelOut
);
    reg [31:0]temp32[0:31];
    reg [31:0]temp16[0:15];
    reg [31:0]temp8[0:7];
    reg [31:0]temp4[0:3];
    reg [31:0]temp2[0:1];

    always@(posedge clk or negedge nRST) begin
        if (!nRST) begin
            labelOut <= 0;
        end else if (EN) begin
            labelOut <= labelIn;
        end
    end

    generate
        genvar i;  
        for (i = 0; i <= 31; i=i+1) begin
            always@(posedge clk or negedge nRST) begin
                if (!nRST) begin
                    temp32[i] <= 32'b0;
                end else if (EN) begin
                    temp32[i] <= dataIn2[i] == 0 ? 0 : dataIn1 << i;
                end
            end
        end

        for (i = 0; i <= 15; i=i+1) begin
            always@(posedge clk or negedge nRST) begin
                if (!nRST) begin
                    temp16[i] <= 32'b0;
                end else begin
                    temp16[i] <= temp32[i] + temp32[i + 16];
                end
            end
        end

        for (i = 0; i <= 7; i=i+1) begin
            always@(posedge clk or negedge nRST) begin
                if (!nRST) begin
                    temp8[i] <= 32'b0;
                end else begin
                    temp8[i] <= temp16[i] + temp16[i + 8];
                end
            end
        end

        for (i = 0; i <= 3; i=i+1) begin
            always@(posedge clk or negedge nRST) begin
                if (!nRST) begin
                    temp4[i] <= 32'b0;
                end else begin
                    temp4[i] <= temp8[i] + temp8[i + 4];
                end
            end
        end
    endgenerate
    always@(posedge clk or negedge nRST) begin
        if (!nRST) begin
            temp2[0] <= 32'b0;
            temp2[1] <= 32'b0;
            result <= 32'b0;
        end else begin
            temp2[0] <= temp4[0] + temp4[2];
            temp2[1] <= temp4[1] + temp4[3];
            result <= temp2[0] + temp2[1];
        end
    end
endmodule