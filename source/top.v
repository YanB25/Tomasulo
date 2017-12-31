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

    ReservationStation alu_reservationstation(
        .clk(clk),
        .nRST(nRST),
        .EXEable(),
        .WEN(),
        .opCode(),
        .dataIn1(),
        .label1(),
        .dataIn2(),
        .label2(),

        .BCEN,
        .BClabel,
        .BCdata,

        .opOut(),
        .dataOut1(),
        .DataOut2(),
        .isFull(),
        .OutEn(),
        .labelOut(), 
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