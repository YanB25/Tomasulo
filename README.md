# Tomasulo
## Description
An out-of-order execution algorithm for pipeline CPU.  
Project for `computer organization principles course`
## Installation
``` bash
$ git clone git@github.com:YanB25/Tomasulo.git
```
## Usage
Manually add all the files in `scource/` into `vivado` and just run.  
Add files in `test/`, set one of them *as top* to try the testcases.
## Algorithm Introduction
From [wiki](wiki)
> Tomasulo’s algorithm is a computer architecture hardware algorithm for dynamic scheduling of instructions that allows out-of-order execution and enables more efficient use of multiple execution units. It was developed by Robert Tomasulo at IBM in 1967.


### The Whole Picture
<img src="/doc/pic/overview.png" style="height:15em"/>

### Terminology
1. 块
存储信息的单位。若干有关联的数据放在一起称为块。例如op和func和rs,rd,rt等存储在一起，称为一个块。
1. 标志位
用于标志“是”或“否”的位。
1. 行
一行包括一个块和对应的标志位
## Instruction Set
支持除分支指令外的大部分常用MIPS指令。
[指令集编码][is]
想要[支持更多指令][todo]？
## Component
### PC & ROM
没有从图中画出来。向指令队列发射指令（当指令队列非满时。）
### Instruction Queue
指令队列。由于Tomasulo算法顺序发射指令，故由指令队列保证其发射的顺序性。当一个指令（例如`add`）对应的器件（`ALU`）不忙时，指令发射；否则发生结构冲突，需要阻塞等待。  
[more detail][iq]
### Commom Data Bus
CDB.所有刚执行完得到的数据的广播都要通过该总线完成。  
每个执行器件（如各个ALU）,向CDB Helper发送`require`信号请求广播。  
CDB保证其广播信号在一个周期内不发生更改。
[more detail][cdb]
### CDB Queue
**deprecated.**
不使用CDB队列。  
见CDB Helper  

### Register File
寄存器文件。时序电路。  
当时钟下降沿到达后：
检查CDB的广播，若该广播的数据被监听，则将数据更新入寄存器文件中。  
检查当前指令的`rd`,记录`rd`所等待的label。  
[Details here][rf]
### Reservation Station 
保留站。包括加减ALU保留站和乘除的保留站。  

每个CPU周期，一条算逻运算指令将发射到对应ALU保留站处。  
该指令要么所有的操作数都已准备好（立即可以被执行，label==0），或部分操作数由`label`（label != 0）代替，正等待`CDB`的广播。 
[more detail][rs]
### ALU(FPU)
算术逻辑单或和浮点运算单元。  
不同的运算需要不同的CPU周期完成。由于该种延迟，基于[保留站][rs]的乱序执行可以为其大大提速。
[more detail][alu]




## Bugs & Helps
To report a bug or get help, you can [Issues page][issue].

## Contribute
To offer codes, please contact us in the [Issues page][issue].  
You can refer to [TODO-List][todo] find out what the project still need.  


[rs]:doc/Component/ReservationStation.md
[is]:doc/InstructionSet.md
[iq]:doc/Component/InstructionQueue.md
[cdb]:doc/Component/CommonDataBus.md
[rf]:doc/Component/RegisterFile.md
[alu]:doc/Component/ALUs.md
[wiki]:https://en.wikipedia.org/wiki/Tomasulo_algorithm
[issue]:https://github.com/YanB25/Tomasulo/issues
[todo]:doc/TODO.md