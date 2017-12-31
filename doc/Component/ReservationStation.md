# Reservation Station
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


## IO Ports
> 前提：用于索引label的地址的位数为5

``` verilog
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
```