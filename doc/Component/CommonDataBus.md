# Common Data Bus
## CDB
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
## CDB Helper
一个优先译码器。组合逻辑。  
当各个器件向CDB发送传播请求时（传送1），只有一个器件能得到接受回应（1），其余器件都得到拒绝回应（0）。  
``` verilog
module CDBHelper(
    input [3:0] requires,
    output reg [3:0] accepts
);
```