`timescale 1ns/1ps
module ROM (  
    input nrd, 
    output reg [31:0] dataOut,
    input [31:0] addr
    ); 

    reg [7:0] rom [0:99]; 
    initial begin 
        $readmemh ("C:/Users/Administrator/Desktop/workplace/Tomasulo/rom/rom.txt", rom); 
    end
    always @(*) begin
        if (nrd == 0) begin
            dataOut[31:24] = rom[addr];
            dataOut[23:16] = rom[addr+1];
            dataOut[15:8] = rom[addr+2];
            dataOut[7:0] = rom[addr+3];
        end else begin
            dataOut[31:0] = {32{1'bz}};
        end
    end
endmodule