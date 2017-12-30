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
CDB.所有刚执行完得到的数据的广播都要通过该总线完成。为了避免冲突，还应实现一个队列用于缓存广播数据。  
#### Codes
``` verilog
wire CDB[31:0];
wire CDBLabel[4:0];
wire BCEN; // BroadCast ENable
```
### CDB Queue
canceled.
不使用CDB队列。  
见CDB Helper  
### CDB Helper
#### overview
一个优先译码器。  
当各个器件向CDB发送传播请求时（传送1），只有一个器件能得到回应（1），其余器件都得到拒绝回应（0）。回应将持续一个周期。未得到回应的器件应持续向CDB发送请求，否则数据不会被广播。
#### IO Ports
``` verilog
module CDBHelper(
    input clk,
    input xxx_require,
    input [31:0]xxx_data,
    input yyy_require,
    input [31:0] yyy_data,
    ... // many requires
    
    // determin which component's require is accepted. 
    // Send to CU, and CU send "1" or "0" to all coms.
    output [3:0]accept_id,
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
### Reservation Station (TODO)
#### overview
保留站。包括加减ALU保留站和乘除FPU的保留站。  
每个CPU周期，一条算逻运算指令将发射到对应ALU保留站处。  
该指令要么所有的操作数都已准备好（立即可以被执行，label==0），或部分操作数由`label`（label != 0）代替，正等待`CDB`的广播。 
#### summary
清零信号到达后：
//TODO
四分频时钟上升沿到达后：
1. 将索引i加一
1. 若这是第一个阶段的时钟上升沿，（即索引从3变为0)，则将内部的标志寄存器组清空。

四分频时钟下降沿到达后，
1. 若有来自指令队列的指令且还没被响应(!answer)
    1. 若该行空闲，且指令的操作数都准备好了
    do something
    1. 若该行空闲，且指令的操作数未准备好
    do something
1. 若该行忙，且未能发射，且CDB送来所需要的数据
1. 若该行忙，且能够发射，且ALU空闲，且没有其他`行`想发射
发射指令
busy_item[i]置为0 
#### IO Ports
``` verilog
module ReservationStation(
    input clk_div4,
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
    input EXEable, // whether the ALU is available and ins can be issued
    output dataOut1[31:0],
    output dataOut2[31:0],
    output isFull, // whether the buffer is full
    output OutEn, // whether output is valid
    output [4:0]labelOut
    );
    reg busy_item[3:0]; // which line is busy
    reg answer_item[3:0]; // which line answer to the ins from queue
    reg sendALU_item[3:0]; // which line send data to ALU
```
### multi-cycle ALU
#### overview
多周期ALU。加法1个CPU周期，减法两个。 
ALU内存有状态转换寄存器。分别具有状态`idle`, `plus`, `minus1`, `minus2`  
在idle状态，ALU随时准备好在时钟上升沿接受dataIn
在`plus`和`minus2`状态（即每个操作的最后一个状态），ALU必须等到CDB返回`Accept`才能继续接受下一次的dataIn。  
若CDB返回AC，时钟上升沿到达后：
1. 若保留站请求使用ALU，则根据op将状态转换为`plus`或`minus2`.
1. 若保留站不请求，则状态转为`idle`。

#### IO Ports
//TODO :: split it into state module and alu module
``` verilog
module pmALU ( // plus/minus ALU
    input clk,
    input inEN, // input ENable
    input [31:0] dataIn1,
    input [31:0] dataIn2,
    input pmALUop,
    input resultAC,
    output finished, // send to CDB
    output [31:0] result
);
```
### Store Buffer
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