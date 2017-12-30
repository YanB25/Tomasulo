`timescale 1ns/1ps
`include "head.v"

module LoadStation(
    input clk,
    input EXEable, // whether the ALU is available and ins can be issued
    input WEN, // Write ENable

    input [4:0] opCode,
    input [4:0] func,
    input [31:0] dataIn1,
    input [4:0] label1,
    input [31:0] Imm,
    // input [31:0] dataIn2,
    // input [4:0] label2,

    input BCEN, // BroadCast ENable
    input [4:0] BClabel, // BoradCast label
    input [31:0] BCdata, //BroadCast value

    output reg [4:0] opOut,
    output reg [31:0] dataOut1,
    output reg [31:0] dataOut2,
    output isFull, // whether the buffer is full
    output OutEn, // whether output is valid
    output [4:0]labelOut
    );


    // 设置了三个保留站
    // 若使b2'11来索引，无效
    reg Busy[2:0];
    reg [4:0]Op[2:0];
    reg [4:0]Qj[2:0];
    reg [31:0]Vj[2:0];
    reg [31:0]A[2:0];
    // reg [4:0]Qk[2:0];
    // reg [31:0]Vk[2:0];

    // 当前可写地址 ,2'b11则为不可写?
    reg [1:0] cur_addr ;
    // 当前就绪地址,2'b11则为不可写?
    reg [1:0] ready_addr ;
    initial begin
        Busy[0] = 0;
        Busy[1] = 0;
        Busy[2] = 0;
    end
    
    always@(posedge clk) begin
        if (EXEable == 1 && ready_addr != 2'b11) begin
            Busy[ready_addr] <= 0;
        end
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
            A[cur_addr] = Imm;
        end
        //  maybe generate latch
    
        // 从CDB总线中写
        if (BCEN == 1 ) begin 
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
        end
    end    
    
    always@(*) begin
        if (EXEable == 1 && ready_addr != 2'b11) begin
            opOut = Op[ready_addr];
            dataOut1 = Vj[ready_addr];
        end
        // maybe generate latch
    end
    
    // 优先译码，使用组合逻辑生成当前可写地址
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
    // 计算当前就绪地址，以及就绪状态?
    always@(*)begin
        if (Busy[0] == 1 && Qj[0] == 0) begin
            ready_addr = 2'b00;
        end
        else begin
            if(Busy[1] == 1 && Qj[1] == 0) begin
                ready_addr = 2'b01;
            end
            else begin 
                if (Busy[2] == 1 && Qj[2] == 0) begin
                    ready_addr = 2'b10;
                end
                else 
                    ready_addr = 2'b11;
            end
        end
    end

    assign OutEn = ~ (&ready_addr);

    // 保留站号?
    assign labelOut = {0,0,0,ready_addr};

endmodule