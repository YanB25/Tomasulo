`timescale 1ns/1ps
`include "head.v"

module ReservationStation(
    input clk,
    input nRST,
    input EXEable, // whether the ALU is available and ins can be issued
    input WEN, // Write ENable

    input [1:0] ResStationDst,// TODO:
    input [1:0] opCode,
    input [31:0] dataIn1,
    input [3:0] label1,
    input [31:0] dataIn2,
    input [3:0] label2,

    input BCEN, // BroadCast ENable
    input [3:0] BClabel, // BoradCast label
    input [31:0] BCdata, //BroadCast value

    output [1:0] opOut,
    output [31:0] dataOut1,
    output [31:0] dataOut2,
    output isFull, // whether the buffer is full
    output OutEn, // whether output is valid
    output [3:0] ready_labelOut,
    output [3:0] writeable_labelOut
    );

    // 设置了三个保留站
    // 若使b2'11来索引，无效
    reg Busy[2:0];
    reg [1:0]Op[2:0];
    reg [3:0]Qj[2:0];
    reg [31:0]Vj[2:0];
    reg [3:0]Qk[2:0];
    reg [31:0]Vk[2:0];

    // 当前可写地址 ,2'b11则为不可�??
    reg [1:0] cur_addr ;
    // 当前就绪地址,2'b11则为不可�??
    reg [1:0] ready_addr ;
    initial begin
        Busy[0] = 0;
        Busy[1] = 0;
        Busy[2] = 0;
    end
    
    always@(posedge clk or negedge nRST) begin
        if (nRST == 0) begin 
            Busy[0] <= 0;
            Busy[1] <= 0;
            Busy[2] <= 0;
        end
        else begin 
            if (WEN == 1) begin
                if (cur_addr != 2'b11 && Busy[cur_addr] == 0) begin
                    Busy[cur_addr] <= 1;
                    Op[cur_addr] <= opCode;
                    if (BCEN == 1 & label1 == BClabel) begin
                        Qj[cur_addr] <= 0;
                        Vj[cur_addr] <= BCdata;
                    end
                    else begin
                        Qj[cur_addr] <= label1;
                        Vj[cur_addr] <= dataIn1;
                    end
                    if (BCEN == 1 && label2 == BClabel) begin
                        Qk[cur_addr] <= 0;
                        Vk[cur_addr] <= BCdata;
                    end
                    else begin
                        Qk[cur_addr] <= label2;
                        Vk[cur_addr] <= dataIn2;
                    end
                end
                //  maybe generate latch
            end
            // watch CDB
            if (BCEN == 1 ) begin 
                if (BClabel[3:2] == ResStationDst) begin
                    Busy[BClabel[1:0]] <= 0;
                end
                if (Busy[0] == 1 && Qj[0] == BClabel) begin
                    Vj[0] = BCdata;
                    Qj[0] = 0;
                end
                if (Busy[1] == 1 && Qj[1] == BClabel) begin
                    Vj[1] = BCdata;
                    Qj[1] = 0;
                end
                if (Busy[2] == 1 && Qj[2] == BClabel) begin
                    Vj[2] = BCdata;
                    Qj[2] = 0;
                end
                if (Busy[0] == 1 && Qk[0] == BClabel) begin
                    Vk[0] = BCdata;
                    Qk[0] = 0;
                end
                if (Busy[1] == 1 && Qk[1] == BClabel) begin
                    Vk[1] = BCdata;
                    Qk[1] = 0;
                end
                if (Busy[2] == 1 && Qk[2] == BClabel) begin
                    Vk[2] = BCdata;
                    Qk[2] = 0;
                end
            end
        end
    end    
    

    assign opOut = Op[ready_addr];
    assign dataOut1 = Vj[ready_addr];
    assign dataOut2 = Vk[ready_addr];
    
    // 优先译码，使用组合�?�辑生成当前可写地址
    // 若为2'b11则不可写
    always@(*) begin
        if (Busy[0] == 0) begin
            cur_addr = 2'b00;
        end
        else if (Busy[1] == 0) begin
            cur_addr = 2'b01;
        end
        else if (Busy[2] == 0) begin
            cur_addr = 2'b10;
        end
        else
            cur_addr = 2'b11;
    end

    // 保留站是否满
    assign isFull = & cur_addr;

    // 是否就绪
    // 计算当前就绪地址，以及就绪状�??
    always@(*)begin
        if (Busy[0] == 1 && Qj[0] == 0 && Qk[0] == 0) begin
            ready_addr = 2'b00;
        end
        else begin
            if(Busy[1] == 1 && Qj[1] == 0 && Qk[1] == 0) begin
                ready_addr = 2'b01;
            end
            else begin 
                if (Busy[2] == 1 && Qj[2] == 0 && Qk[2] == 0 ) begin
                    ready_addr = 2'b10;
                end
                else 
                    ready_addr = 2'b11;
            end
        end
    end

    assign OutEn = ~ (&ready_addr);

    assign ready_labelOut = {ResStationDst,ready_addr};// TODO:
    assign writeable_labelOut = {ResStationDst, cur_addr};

endmodule