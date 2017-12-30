`timescale 1ns/1ps
`include "head.v"

module ReservationStation(
    input clk,
    input EXEable, // whether the ALU is available and ins can be issued
    input WEN, // Write ENable

    input opCode[4:0],
    input func[4:0],
    input dataIn1[31:0],
    input label1[4:0],
    input dataIn2[31:0],
    input label2[4:0],

    input BCEN, // BroadCast ENable
    input BClabel[4:0], // BoradCast label
    input BCdata[31:0], //BroadCast value

    output reg opOut[4:0];
    output reg dataOut1[31:0],
    output reg dataOut2[31:0],
    output isFull, // whether the buffer is full
    output OutEn, // whether output is valid
    output [4:0]labelOut
    );

    // 设置了三个保留站
    // 若使用2'11来索引，无效
    reg [2:0]Busy;
    reg [2:0]Op[4:0];
    reg [2:0]Qj[4:0];
    reg [2:0]Vj[31:0];
    reg [2:0]Qk[4:0];
    reg [2:0]Qj[4:0];

    // 当前可写地址 ,若2'b11则为不可写
    reg cur_addr [1:0];
    // 当前就绪地址,若2'b11则为不可写
    reg ready_addr [1:0];
    integer i,j,k;

    always@(posedge clk) begin
        if (cur_addr != 2'b11 && Busy[cur_addr] == 0) begin
            Busy[cur_addr] <= 1;
            Op[cur_addr] <= opCode;
            Qj[cur_addr] <= label1;
            Vj[cur_addr] <= dataIn1;
            Qk[cur_addr] <= label2;
            Vk[cur_addr] <= dataIn2;
        end
        //  maybe generate latch
    
        // 从CDB总线中写回
        if (BCEN == 1 && WEN = 1) begin 
            for (i = 0; i < 2; i = i+1) begin
                if (Busy[i] == 1 && Qj[i] == BClabel) begin
                    Vj[i] = BCdata;
                    Qj[i] = 0;
                end
            end
            for (j = 0; j < 2; j = j+1) begin
                if (Busy[j] == 1 && Qk[j] = BClabel) begin
                    Vk[j] = BCdata;
                    Qk[j] = 0;
                end
            end
        end
    end    
    
    always@(negedge clk) begin
        if (EXEable == 1 && ready_addr != 2'b11) begin
            opOut <= Op[ready_addr];
            dataOut1 <= Vj[ready_addr];
            dataOut2 <= Vk[ready_addr];
            Busy[read_addr] <= 0;
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
    // 计算当前就绪地址，以及就绪状态
    always@(*)begin
        if (Busy[0] == 1 && Qj[0] == 0 && Qk[0] == 0) begin
            ready_addr = 2'b00;
        end
        else if(Busy[1] == 1 && Qj[1]] == 0 && Qk[1] == 0) begin
            ready_addr = 2'b01;
        end
        else if (Busy[2] == 1 && Qj[2] == 0 && Qk[2] == 0 ) begin]
            ready_addr = 2'b10;
        end
        else 
            ready_addr = 2'b11;
    end

    assign OutEn = & ready_addr;

    // 保留站号，暂时前缀为00，可能会改
    assign labelOut = {0,0,ready_addr};

endmodule