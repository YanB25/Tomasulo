`timescale 1ns/1ps

module Memory(
    input clk,
    input WEN,
    input [31:0] dataIn1,// Qj
    input [31:0] dataIn2,// A 
    input op,// for example, 1 is load, 0 is write
    input [31:0] writeData,
    input [3:0] labelIn,
    output reg [3:0] labelOut, 
    output [31:0] loadData,
    output reg available,
    output reg require,
    input requireAC,
    output isLastState
);
    reg [31:0] addr;
    reg nRD;
    reg nWR;
    integer States;
    initial begin
        States = 0;
        nRD = 1;
        nWR = 1;
        require = 0;
    end 
    wire readStatus;
    wire writeStatus;
    always@( posedge clk ) begin
        if (States == 0) begin
            if (WEN == 1) begin
                addr <= dataIn1 + dataIn2;
                labelOut <= labelIn;
                States <= 1;
            // States 从0 变成1，进入访存阶段
                if (op == 1) begin
                    nRD <= 0;
                end
                if (op == 0) begin
                    nWR <= 0;
                end
            end
            else begin // WEN == 0
                States <= 0;
                nRD <= 1;
                nWR <= 1;
            end
        end
        else if (States == 1) begin
                nRD <= 1;
                nWR <= 1;
                if (readStatus == 1) begin
                    States <= 2;
                    require <= 1;
                end
                if (writeStatus == 1) begin
                    require <= 0;
                    States <= 0;
                end
            end
        else if (States == 2) begin
            if (requireAC == 1) begin
                States <= 0;
            end
            else begin
                States <= 2;
            end
        end
        else 
            States <= 4;
    end

    always@(*) begin
        if (States == 1 || States == 2) begin
            available = 0;
        end
        else begin
            available = 1; //TODO :maybe bugs not a good implementation
        end
    end

    RAM my_ram(
        .clk(clk),
        .address(addr),
        .writeData(writeData),
        .Dataout(loadData),
        .readStatus(readStatus),
        .writeStatus(writeStatus),
        .nRD(nRD),
        .nWR(nWR),
        .isLastState(isLastState)
    );

endmodule