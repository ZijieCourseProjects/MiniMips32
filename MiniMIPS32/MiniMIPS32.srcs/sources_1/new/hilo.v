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
    
    //д�˿�
    input   wire[`WE_HILO]       we,
    input   wire[`REG_BUS]      hi_i,
    input   wire[`REG_BUS]      lo_i,
    
    //���˿�
    output  reg [`REG_BUS]      hi_o,
    output  reg [`REG_BUS]      lo_o
    );
    
    always @(posedge cpu_clk_50M) begin
        if(we==2'b11) begin
        hi_o<=hi_i;//���˷����mulres��ǰ32λ��HI�Ĵ���
        lo_o<=lo_i;//���˷����mulres�ĺ�32λ��IO�Ĵ���
        end
        
        else if(we==2'b10)
        hi_o<=hi_i;//��MTHI��ǰ32λ��HI�Ĵ���
        
        else if(we==2'b01)
        lo_o<=lo_i;//��MTLO�ĺ�32λ��IO�Ĵ���
        
        else;
    
    end
    
endmodule
