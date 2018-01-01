`timescale 1ns/1ps
`include "head.v"
// implement as queue.
module Queue(
    input clk,
    input nRST,
    input requireAC, // whether the ALU is available and ins can be issued
    input WEN, // Write ENable
    output isFull, // whether the buffer is full
    output require, // whether output is valid

    input [31:0] dataIn,
    input [3:0] labelIn,
    input opIN,

    input BCEN, // BroadCast ENable
    input [3:0] BClabel, // BoradCast label
    input [31:0] BCdata, //BroadCast value

    output opOut,
    output [31:0] dataOut,
    output [3:0] labelOut,
    input isLastState,
    output [3:0] queue_writeable_label
    );
    reg [3:0]availableIdLabel;
    assign queue_writeable_label = availableIdLabel;
    reg [3:0]Busy;
    reg [3:0]Label[3:0];
    reg [31:0]Data[3:0];
    reg [3:0]IdLabel[3:0];
    reg [3:0]op;
    initial begin
        Label[3] = 0;
        Busy[3] = 4'b1000;
        Data[3] = 0;
        IdLabel[3] = 0;
        op[3] = 0;
    end
    assign opOut = op[0];
    assign dataOut = Data[0];
    assign labelOut =IdLabel[0];

    wire issuable = require && requireAC;
    wire wbusy = Busy[0] && Busy[1] && Busy[2];
    assign isFull = !issuable && wbusy;
    assign require = Busy[0] && Label[0] == 0;
    wire poppable;
    assign poppable = isLastState;
    
    reg [1:0] first_empty;
    always@(*) begin
        if (!Busy[0]) first_empty = 0;
        else if (!Busy[1]) first_empty = 1;
        else first_empty = 2;
    end

    reg [1:0]lastBusyIndex;
    always@(*) begin
        if (Busy[2])
            lastBusyIndex = 2;
        else if (Busy[1])
            lastBusyIndex = 1;
        else if (Busy[0])
            lastBusyIndex = 0;
        else lastBusyIndex = -1;
    end

    always@(*) begin
        if (wbusy) 
            availableIdLabel = 4'bx; // if busy, it is don't-care signal
        else if (IdLabel[0] != `QUE0 && IdLabel[1] != `QUE0 && IdLabel[2] != `QUE0)
            availableIdLabel = `QUE0;
        else if (IdLabel[0] != `QUE1 && IdLabel[1] != `QUE1 && IdLabel[2] != `QUE1)
            availableIdLabel = `QUE1;
        else availableIdLabel = `QUE2;
    end

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
                    if (!poppable) begin
                        if (!wbusy && i == first_empty) begin //Wen && !issuable && !busy
                            // input data to the first empty position
                            Busy[i] <= 1;
                            Data[i] <= BCEN && BClabel==labelIn ? BCdata : dataIn;
                            Label[i] <= BCEN && BClabel == labelIn ? 0 : labelIn;
                            op[i] <= opIN;
                            IdLabel[i] <= availableIdLabel;
                        end else begin
                            if (BCEN && BClabel == Label[i]) begin // else watch for bc
                                Data[i] <= BCdata;
                                Label[i] <= 0;
                            end
                        end 
                    end else begin
                        if (!wbusy && i == lastBusyIndex) begin // WEN && issuable : queue must be available
                            // Busy is also 1, so do not change
                            Data[i] <= BCEN && BClabel == labelIn ? BCdata : dataIn;
                            Label[i] <= BCEN && BClabel ==  labelIn ? 0 : labelIn;
                            op[i] <= opIN;
                            IdLabel[i] <= availableIdLabel;
                        end else if (i < lastBusyIndex) begin // queue::pop()
                            Data[i] <= BCEN && BClabel == Label[i+1]? BCdata : Data[i+1];
                            Label[i] <= BCEN && BClabel == Label[i+1] ? 0 : Label[i+1];
                            op[i] <= op[i+1];
                            IdLabel[i] <= IdLabel[i+1];
                        end
                    end
                end else begin
                    if (poppable) begin
                        if (i == lastBusyIndex) begin //!Wen && issuable
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
                    end else begin //!WEN && !issuable
                        if (BCEN && BClabel == Label[i]) begin
                            Data[i] <= BCdata;
                            Label[i] <= 0;
                        end
                    end
                end
            end
        end
    endgenerate
endmodule