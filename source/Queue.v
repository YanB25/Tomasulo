`timescale 1ns/1ps
`include "head.v"
// implement as queue.
module RAMStation(
    input clk,
    input nRST,
    input requireAC, // whether the ALU is available and ins can be issued
    input WEN, // Write ENable
    output isFull, // whether the buffer is full
    output require, // whether output is valid

    input [31:0] dataIn,
    input [4:0] labelIn,
    input opIN,

    input BCEN, // BroadCast ENable
    input [4:0] BClabel, // BoradCast label
    input [31:0] BCdata, //BroadCast value

    output opOut,
    output [31:0] dataOut,
    output [31:0] labelOut,
    );

    reg Busy[2:0];
    reg [4:0]Label[2:0];
    reg [31:0]Data[2:0];
    reg [4:0]IdLabel[2:0];
    reg op[2:0];

    assign opOut = op[0];
    assign dataOut = Data[0];
    assign labelOut =IdLabel[0];

    wire wbusy = & Busy;
    assign isFull = !requireAC && wbusy;
    assign require = Busy[0] && Label[0] == 0;

    reg [1:0]lastBusyIndex;
    always@(*) begin
        if (Busy[2])
            lastBusyIndex = 2;
        else if (Busy[1])
            lastBusyIndex = 1;
        else if (Busy[i])
            lastBusyIndex = 0;
        else lastBusyIndex = -1;
    end

    reg [4:0] availableIdLabel;
    always@(*) begin
        if (wbusy) // if busy, just assign the being popped item's idlabel to availableIdLabel
            availableIdLabel = IdLabel[0];
        else if (IdLabel[0] != `q0 && IdLabel[1] != `q0 && IdLabel[2] != `q0)
            availableIdLabel = `q0;
        else if (IdLabel[0] != `q1 && IdLabel[1] != `q1 && IdLabel[2] != `q1)
            availableIdLabel = `q1;
        else availableIdLabel = `q2;


    generate
        genvar i;
        for (i = 0; i <= 2; i = i + 1) begin
            always@(posedge clk or negedge nRST) begin
                if (!nRST) begin
                    Busy[i] <= 0;
                    Label[i] <= 0;
                    Data[i] <= 0;
                    IdLabel[i] <= 0;
                    op[i] <= 0;
                end else if (WEN) begin
                    if (!requireAC) begin
                        if (!wbusy && i == lastBusyIndex+1) begin //Wen && !AC && !busy
                            // input data to the first empty position
                            Busy[i] <= 1;
                            Data[i] <= BCEN && BClabel==Label[i] ? BCdata : dataIn;
                            Label[i] <= BCEN && BClabel == labelIn ? 0 : labelIn;
                            op[i] <= opIn;
                            IdLabel[i] <= availableIdLabel;
                        end 
                    end else begin
                        if (i == lastBusyIndex) begin // WEN && AC : queue must be available
                            // Busy is also 1, so do not change
                            Data[i] <= BCEN && BClabel == labelIn ? BCdata : dataIn;
                            Label[i] <= BCEN && BClabel ==  labelIn ? 0 : labelIn;
                            op[i] <= opIn;
                            IdLabel[i] <= availableIdLabel;
                        end else if (i < lastBusyIndex) begin // queue::pop()
                            Data[i] <= BCEN && BClabel == Label[i+1]? BCdata : Data[i+1];
                            Label[i] <= BCEN && BClabel == Label[i+1] ? 0 : Label[i+1];
                            op[i] <= op[i+1];
                            IdLabel[i] <= IdLabel[i+1];
                        end
                    end
                end else begin
                    if (requireAC) begin
                        if (i == lastBusyIndex) begin //!Wen && AC
                            Busy[i] <= 0;
                            Data[i] <= 0;
                            Label[i] <= 0;
                            op[i] <= 0;
                            IdLabel[i] <= 0;
                        end else if (i < lastBusyIndex) begin
                            Busy[i] <= Busy[i+1];
                            Data[i] <= BCEN && BClabel == Label[i+1] ? BCdata : Data[i+1];
                            Label[i] <= BCEN && BClabel ==  Label[i+1] ? 0 : Label[i+1];
                            op[i] <= op[i+1];
                            IdLabel[i] <= IdLabel[i+1];
                        end
                    end
                end
            end
        end
    endgenerate
endmodule