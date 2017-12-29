# Tomasulo
An out-of-order execution algorithm for pipeline CPU.  
Project for `computer organization principles course`
[toc]
## overview
![](/doc/pic/overview.png)
## Component
### PC & ROM
没有从图中画出来。向指令队列发射指令（当指令队列非满时。）
### Instruction Queue
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
### Register File
#### overview
寄存器文件。对每个寄存器，保存`value[31:0]`, `label[4:0]`, `Watching`  
value:寄存器的内容  
wathcing:是否正在等待CDB广播数据  
label:当watching为yes时，标志等待的数据所在的位置。  
#### IO ports
``` verilog
module RegisterFile(
    input read1[4:0],
    input read2[4:0],
    output watching1,
    output dataOut1[31:0],
    output label1[4:0],
    output watching2,
    output dataOut[31:0],
    output label2[4:0]
    );
```
### Reservation Station
#### overview
保留站。包括加减ALU保留站和乘除FPU的保留站。
每个CPU周期，一条算逻运算指令将发射到对应ALU保留站处。  
该指令要么所有的操作数都已准备好（立即可以被执行），或部分操作数由`label`代替，正等待`CDB`的广播。  
#### IO Ports
``` verilog
module ReservationStation(
    input clk,
    input WEN, // Write ENable
    input opCode[4:0],
    input func[4:0],
    input w1, //watching 1
    input value1[31:0],
    input label1[4:0],
    input w2,
    input value2[31:0],
    input label2[4:0],
    input BCEN, // BroadCast ENable
    input BClabel[4:0], // BoradCast label
    input BCvalue[31:0], //BroadCast value
    output dataOut1[31:0],
    output dataOut2[31:0],
    output OEN, // output ENable
    );
```