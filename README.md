# Tomasulo
An out-of-order execution algorithm for pipeline CPU.  
Project for `computer organization principles course`

[toc]
## overview
![](/doc/pic/overview.png)
## terminology
1. 块
存储信息的单位。若干有关联的数据放在一起称为块。例如op和func和rs,rd,rt等存储在一起，称为一个块。
1. 标志位
用于标志“是”或“否”的位。
1. 行
一行包括一个块和对应的标志位
## Component
### PC & ROM
没有从图中画出来。向指令队列发射指令（当指令队列非满时。）
### Instruction Queue
#### overview
指令队列。由于Tomasulo算法顺序发射指令，故由指令队列保证其发射的顺序性。当一个指令（例如`add`）对应的器件（`ALU`）不忙时，指令发射；否则发生结构冲突，需要阻塞等待。  
#### IO Prots
``` verilog
module Queue(
    input clk,
    input insIn[31:0],
    output isFull,
    output insOut[31:0]
    )
```
### Commom Data Bus
#### overview
CDB.所有刚执行完得到的数据的广播都要通过该总线完成。  
每个执行器件（如各个ALU）,向CDB Helper发送`require`信号请求广播。  
CDB保证其广播信号在一个周期内不发生更改。
``` verilog
module CDB(
    input [31:0] data0,
    input [4:0] label0,
    input [31:0] data1,
    input [4:0] label1,
    input [31:0] data2,
    input [4:0] label2,
    input [31:0] data3,
    input [4:0] label3,
    input [3:0] sel,
    output [31:0] dataOut,
    output [4:0] labelOut,
    output EN
);
```
### CDB Queue
canceled.
不使用CDB队列。  
见CDB Helper  
### CDB Helper
#### overview
一个优先译码器。组合逻辑。  
当各个器件向CDB发送传播请求时（传送1），只有一个器件能得到接受回应（1），其余器件都得到拒绝回应（0）。  
回应将持续一个周期。回应保证在一个周期内不发生改变。  
回应保证只在时钟上升沿
#### IO Ports
``` verilog
module CDBHelper(
    input [3:0] requires,
    output reg [3:0] accepts
);
```
### Register File
#### overview
寄存器文件。
data:寄存器的内容  
label:当label不为0时，标志等待的数据所在的位置；否则表示数据在寄存器中，可直接被读取。  
#### IO ports
``` verilog
module RegisterFile(
    input readAddr1[4:0],
    input readAddr2[4:0],
    output dataOut1[31:0],
    output label1[4:0],
    output dataOut2[31:0],
    output label2[4:0]
    );
```
### Reservation Station 
#### overview
保留站。包括加减ALU保留站和乘除FPU的保留站。  
每个CPU周期，一条算逻运算指令将发射到对应ALU保留站处。  
该指令要么所有的操作数都已准备好（立即可以被执行，label==0），或部分操作数由`label`（label != 0）代替，正等待`CDB`的广播。 
#### summary
清零信号到达后：

设置了三个保留站
1. 当时钟上升沿到达的时候，
    1. 由信号isFull反映是否可写及写成功，将对应的值写进保留站中
    （不提供控制写地址的端口，只向外界告知是否写成功）
    2. 从CDB中读取信息，若CDB可用，则上升沿写入对应保留站中的寄存器，并修改相应Qi/Qj
2. 时钟下降沿到达时，若保留站中存在操作数就绪的指令，则对外输出就绪指令数据及保留站号
    1. 输入信号EXEable若反映ALU不可用， 则对应Busy位不修改，否则将已输出的指令对应的Busy清零
    2. 输出信号OutEn为0反映输出不可用（指令处于未就绪状态），反之则就绪，ALU可写


#### IO Ports
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
### multi-cycle ALU for plus and minus
#### overview
多周期ALU。时序电路，带状态转换。
接受来自保留站的`inEN`信号，标志是否有新数据请求运算。  
接受来自CDB的`resultAC`信号，标志运算结果是否被广播，若未被广播，需要阻塞直到被广播为止。  
输出`finished`信号到CDB。请求CDB广播。
#### IO Ports
``` verilog
module state(
    input clk,
    input nRST,
    output reg [1:0] stateOut,
    input inEN, // input ENable from reservation
    input resultAC, //whether result is ACcepted by CDB
    output finished, // send to CDB
    input op
);
module pmALU ( // plus/minus ALU
    input clk,
    input nRST,
    input EN,
    input [31:0] dataIn1,
    input [31:0] dataIn2,
    input [1:0] state,
    output reg [31:0] result
);
```
### ALU for multiple and division
#### overview
与多周期加减ALU一致，只是实现方式和状态转换不同
### FLU
#### overview
浮点运算ALU。与多周期加减/乘除ALU一致，只是实现方式和状态转换不同。
### Store Buffer(TODO)
#### overview
Store缓冲器。该缓冲器的容量为4，**采用4分频的时钟信号**。  
#### summary

#### IO Port
``` verilog
module StoreBuffer(
    input clk_div4,
    input [4:0] label,
    input [31:0] base_addr, // from register 
    input [31:0]offset_addr, // from immd
    input [31:0]effective_address, // from ALU
    input [31:0] data,
    input BCEN,
    input [31:0]BCdata,
    input [4:0]BClabel,
    output [31:0]addrOut， // output effective address
    output [31:0] dataOut
);
    reg [31:0] effective_address[0:3];
    reg busy[0:3];
```
### load buffer
#### overview
每个时钟上升沿到达后，接受来自指令队列的`lw`指令。同`store buffer`。  

### ALU for store / load effective address
#### overview
计算store和load缓冲区中的有效地址的专用ALU。  
只执行加法。每个操作仅需一个CPU周期的时间。
#### IO Ports
``` verilog
module ALU_SL(
    input [31:0] data1,
    input [31:0] data2,
    output [31:0] out
);