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
#### overview
CDB队列。当有多组数据同时试图广播时，将它们存储在队列中依次广播。
#### IO Ports
// TODO： YB
### Register File
#### overview
寄存器文件。对每个寄存器，保存`value[31:0]`, `label[4:0]`, `Watching`  
value:寄存器的内容  
label:当label不为0时，标志等待的数据所在的位置；否则表示数据在寄存器中，可直接被读取。  
#### IO ports
``` verilog
module RegisterFile(
    input read1[4:0],
    input read2[4:0],
    output dataOut1[31:0],
    output label1[4:0],
    output dataOut[31:0],
    output label2[4:0]
    );
```
### Reservation Station
#### overview
保留站。包括加减ALU保留站和乘除FPU的保留站。  
每个CPU周期，一条算逻运算指令将发射到对应ALU保留站处。  
该指令要么所有的操作数都已准备好（立即可以被执行，label==0），或部分操作数由`label`（label != 0）代替，正等待`CDB`的广播。  
#### IO Ports
``` verilog
module ReservationStation(
    input clk,
    input WEN, // Write ENable
    input opCode[4:0],
    input func[4:0],
    input value1[31:0],
    input label1[4:0],
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
### Store Buffer
#### overview
Store缓冲器。`sw`指令被发射后，直接进入该缓冲器。该缓冲器中的操作数要么已经准备完成(label == 0), 要么等待CDB广播（label != 0)。
#### IO Port
// TODO!
``` verilog
module StoreBuffer(
    input clk,
    input [31:0]A, // value stored in buffer
);
```
