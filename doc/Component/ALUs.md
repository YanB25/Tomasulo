# ALUs
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