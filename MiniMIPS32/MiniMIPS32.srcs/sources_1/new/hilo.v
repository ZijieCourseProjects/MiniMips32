`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/16 20:58:27
// Design Name: 
// Module Name: hilo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"



module hilo(
    input   wire       cpu_clk_50M,
    input   wire       cpu_rst_n,
    
    //写端口
    input   wire[`WE_HILO]       we,
    input   wire[`REG_BUS]      hi_i,
    input   wire[`REG_BUS]      lo_i,
    
    //读端口
    output  reg [`REG_BUS]      hi_o,
    output  reg [`REG_BUS]      lo_o
    );
    
    always @(posedge cpu_clk_50M) begin
        if(we==2'b11) begin
        hi_o<=hi_i;//将乘法结果mulres的前32位给HI寄存器
        lo_o<=lo_i;//将乘法结果mulres的后32位给IO寄存器
        end
        
        else if(we==2'b10)
        hi_o<=hi_i;//将MTHI的前32位给HI寄存器
        
        else if(we==2'b01)
        lo_o<=lo_i;//将MTLO的后32位给IO寄存器
        
        else;
    
    end
    
endmodule
