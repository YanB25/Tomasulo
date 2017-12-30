`timescale 1ns/1ps
module ROM (  
    input nrd, 
    output reg [31:0] dataOut,
    input [31:0] addr
    ); // 存储器模�??

    reg [7:0] rom [0:99]; // 存储器定义必须用reg类型，存储器存储单元8位长度，�??100个存储单�??
    initial begin // 加载数据到存储器rom。注意：必须使用绝对路径，如：E:/Xlinx/VivadoProject/ROM/（自己定�??
        $readmemh ("C:/Users/Administrator/Desktop/workplace/multiCycleCPU/RomData/data.txt", rom); // 数据文件rom_data�??.coe�??.txt）�?�未指定，就�??0地址�??始存放�??
    end
    always @(*) begin
        if (nrd == 0) begin// �??0，读存储器�?�大端数据存储模�??
            dataOut[31:24] = rom[addr];
            dataOut[23:16] = rom[addr+1];
            dataOut[15:8] = rom[addr+2];
            dataOut[7:0] = rom[addr+3];
        end else begin
            dataOut[31:0] = {32{1'bz}}; //TODO : maybe bug
        end
    end
endmodule