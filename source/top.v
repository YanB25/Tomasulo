`include "head.v"
`timescale 1ns/1ps
module top(
    input clk,
    input nRST
);
    //TODO:: not finished 
    reg pcWrite = 1;
    reg [1:0]sel = 0;
    //TODO END
    wire [31:0] pc;
    wire [31:0] newpc;
    wire [31:0] ins;
    wire [5:0] op;
    wire [5:0] func;
    wire [4:0] sftamt;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [15:0] immd16,
    wire [25:0] immd26;
    wire [31:0] rsData;
    wire [31:0] rtData;
    wire [3:0] rsLabel;
    wire [3:0] rtLabel;
    wire BCEN;
    wire [31:0] BCdata;
    wire [3:0] BClabel;
    PC pc(
        .clk,
        .nRST,
        .newpc,
        .pcWrite,
        .pc
    );
    PCHelper pc_helper(
        .pc,
        .immd16,
        .immd26,
        .sel,
        .rs(0), // rs here is data
        .newpc
    );
    Rom rom(
        .nrd(0),
        .dataOut(ins),
        .addr(pc)
    );
    Decoder decoder(
        .ins,
        .op,
        .func,
        .sftamt,
        .rs,
        .rt,
        .rd,
        .immd16,
        .immd26
    );
    RegFile regfile(
        .clk,
        .nRST,
        .ReadAddr1(rs), // TODO
        .ReadAddr2(rt),
        .RegWr(RegWr),
        .WriteAddr(rd),
        .WriteLabel(), //TODO
        .DataOut1(rsData),
        .DataOut2(rtData),
        .LabelOut1(rsLabel),
        .LabelOut2(rtLabel),
        .BCEN,
        .BClabel,
        .BCdata
    );


    // 假设已经搞定，译码完成，以下就是我想要的
    wire [3:0] sel_alu;// 3,2,1,0 : lw,div,mul,alu
    wire op;
    wire [1:0] ResStationDst
    wire [3:0] Qj;
    wire [3:0] Qk;
    wire [31:0] Vj;
    wire [31:0] Vk;
    wire [31:0] Qi;
    wire [31:0] A;

    wire alu_op;
    wire alu_A;
    wire alu_B;
    wire alu_isReady;
    wire alu_label;
    wire alu_isfull;

    ReservationStation alu_reservationstation(
        .clk(clk),
        .nRST(nRST),
        .EXEable(),// TODO:
        .WEN(sel_alu[0]),
        .ResStationDst(ResStationDst),
        .opCode(op),
        .dataIn1(Vj),
        .label1(Qj),
        .dataIn2(Vk),
        .label2(Qk),
        .BCEN,
        .BClabel,
        .BCdata,
        .opOut(alu_op),
        .dataOut1(alu_A),
        .DataOut2(alu_B),
        .isFull(alu_isfull),
        .OutEn(alu_isReady),
        .labelOut(alu_label), 
    );




    wire mul_op;
    wire mul_A;
    wire mul_B;
    wire mul_label;
    wire mul_isfull;
    wire mul_isReady;

    ReservationStation mul_reservationstation(
        .clk(clk),
        .nRST(nRST),
        .EXEable(),// TODO:
        .WEN(sel_alu[1]),
        .ResStationDst(ResStationDst),
        .opCode(op),
        .dataIn1(Vj),
        .label1(Qj),
        .dataIn2(Vk),
        .label2(Qk),
        .BCEN,
        .BClabel,
        .BCdata,
        .opOut(mul_op),
        .dataOut1(mul_A),
        .DataOut2(mul_B),
        .isFull(mul_isfull),
        .OutEn(mul_isReady),
        .labelOut(mul_label), 
    );

    Queue load_store_queue(
        .clk,
        .nRST,
        .requireAC(),
        .WEN(),
        .isFull(),
        .require(),

        .dataIn(),
        .labelIn(),
        .opIN(),
        .BCEN,
        .BClabel,
        .BCdata,
        .opOut(),
        .dataOut(),
        .labelOut()
    );





endmodule