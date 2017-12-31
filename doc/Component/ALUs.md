# ALUs
Tomasulo算法利用动态调度的方法，充分发挥出多个ALU的效率。  
本项目现实现了`定点数加减ALU`，`定点数乘法ALU`，和`定点数除法ALU`。  
其中各个运算指令所消耗的CPU周期如下。
|Instruction|Cycle(s)|
|:-:|:-:|
|add|1|
|sub|2|
|and|1|
|or|1|
|sll|1|
|slt|1|
|multiplication|5|
|division|32|
Tomasulo算法将动态调度指令执行顺序、避免读写冲突，尽可能地减少ALU的闲置，提高ALU效率。
## Common Signal
各个ALU都具有如下的各个信号。
``` verilog
input WEN;
input requireAC; // for require accepted
output require;
output busy;
```
`WEN`信号表示是否有来自上一级的请求。例如列队中是否存在等待计算的数据。若`WEN`为0，下一个周期后，ALU将进入`idle`（闲置）状态，知道新任务来临。  
`require`信号表示ALU已工作完毕，请求（require）`CDB`总线广播数据。  
`requireAC`表示`CDB`总线接受请求，予以广播。由于总线采用分时复用的方式运作，当`requireAC`返回0时，代表总线忙，广播请求被拒绝。  
`busy`表示ALU正在工作。busy为1时将拒绝来自上一级的运算请求。  
## ALU for Add and Sub
负责加减运算。
//TODO
``` verilog
module state(
    input clk,
    input nRST,
    output reg [1:0] stateOut,
    input WEN, // input ENable from reservation
    input resultAC, //whether result is ACcepted by CDB
    output require, // send to CDB
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
## ALU for multiple
与多周期加减ALU一致，只是实现方式和状态转换不同
## ALU for division