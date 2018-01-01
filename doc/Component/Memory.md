# Memory
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/dwyl/esta/issues)

## summary
1. 第一个


## I/O port
```

module Memory(
    input clk,                      // 时钟信号
    input WEN,                      // 可写信号，高电平有效
    input [31:0] dataIn1,           // 操作数1, 来自rs寄存器
    input [31:0] dataIn2,           // 操作数2, 来自立即数
    input op,                       // for example, 1 is load, 0 is write
    input [31:0] writeData,         // 要写的数据
    input [3:0] labelIn,            // 当前指令的保留站
    output reg [3:0] labelOut,      // 当前指令的保留站
    output [31:0] loadData,         // 当前指令lw， 取出的操作数
    output reg available,           // 存储器是否可用
    output reg require,             // 向CDB请求写入
    input requireAC                 // 向CDB获取写入状态
);


```