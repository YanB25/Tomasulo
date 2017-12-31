# Reservation Station
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/dwyl/esta/issues)
## summary
清零信号到达后：

设置了三个保留站
1. 当时钟上升沿到达的时候，
    1. 由信号isFull反映是否可写及写成功，将对应的值写进保留站中
    （不提供控制写地址的端口，只向外界告知是否写成功）
    2. 从CDB中读取信息，若CDB可用，则上升沿写入对应保留站中的寄存器，并修改相应Qi/Qj
2. 时钟下降沿到达时，若保留站中存在操作数就绪的指令，则对外输出就绪指令数据及保留站号
    1. 输入信号EXEable若反映ALU不可用， 则对应Busy位不修改，否则将已输出的指令对应的Busy清零
    2. 输出信号OutEn为0反映输出不可用（指令处于未就绪状态），反之则就绪，ALU可写

## 编号
|保留站名称|保留站编号|
|:-:|:-:|
|alu0|0000|
|alu1|0001|
|alu2|0010|
|mul0|0100|
|mul1|0101|
|mul2|0110|
|div0|1000|
|div1|1001|
|div2|1010|
|data0|1100|
|data1|1101|
|data2|1110|

## IO Ports
> 前提：用于索引label的地址的位数为5

``` verilog
module ReservationStation(
    input clk,
    input nRST,
    input EXEable, // whether the ALU is available and ins can be issued
    input WEN, // Write ENable

    input [4:0] opCode,
    input [4:0] func,
    input [31:0] dataIn1,
    input [4:0] label1,
    input [31:0] dataIn2,
    input [4:0] label2,

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
```