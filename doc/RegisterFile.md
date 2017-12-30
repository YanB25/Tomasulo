# Register File
## IO Ports
``` verilog
module RegisterFile(
    input clk,
    input nRST,
    input [4:0] ReadAddr1,
    input [4:0] ReadAddr2,
    input RegWr,
    input [4:0] WriteAddr,
    input [31:0] WriteLabel,
    output [31:0] DataOut1,
    output [31:0] DataOut2,
    output [4:0] LabelOut1,
    output [4:0] LabelOut2,
    input BCEN,
    input [4:0] BClabel,
    input [31:0] BCdata
    );
```