`include "defines.v"
//add the output port  mem_aluop_o,which is transmitted to the stage wb,used to distinguish the inst
//L__and inst S__
 module mem_stage (
    
    // 从执行阶段获得的信息
    input  wire [`ALUOP_BUS     ]       mem_aluop_i,
    input  wire [`REG_ADDR_BUS  ]       mem_wa_i,
    input  wire                         mem_wreg_i,
    input  wire [`REG_BUS       ]       mem_wd_i,
    input  wire                         mem_mreg_i,
    input  wire [`REG_BUS       ]       mem_din_i,
    input  wire [`WE_HILO]              mem_whilo_i,
    input  wire [`DOUBLE_REG_BUS]       mem_hilo_i,

    // 送至写回阶段的信�?
    output wire [`REG_ADDR_BUS  ]       mem_wa_o,
    output wire                         mem_wreg_o,
    output wire [`REG_BUS       ]       mem_dreg_o,
    output wire                         mem_mreg_o,
    output wire [`BSEL_BUS      ]       dre,
    output wire [`WE_HILO]              mem_whilo_o,
    output wire [`DOUBLE_REG_BUS]       mem_hilo_o,

    // 送至数据存储器的信息
    output wire                         dce,
    output wire [`INST_ADDR_BUS ]       daddr,
    output wire [`BSEL_BUS      ]       we,
    output wire [`REG_BUS       ]       din,
    output wire [`ALUOP_BUS     ]       mem_aluop_o
    );

    // 如果当前不是访存指令，则只需要把从执行阶段获得的信息直接输出
    assign mem_wa_o     =  mem_wa_i;
    assign mem_wreg_o   = mem_wreg_i;
    assign mem_dreg_o   = mem_wd_i;
    assign mem_whilo_o  = mem_whilo_i;
    assign mem_hilo_o   = mem_hilo_i;
    assign mem_mreg_o   =  mem_mreg_i;
    assign mem_aluop_o   =  mem_aluop_i;

    // 确定当前的访存指�?
    wire inst_lb=(mem_aluop_i == 8'h90);
    wire inst_lw=(mem_aluop_i == 8'h92);
    wire inst_sb=(mem_aluop_i == 8'h98);
    wire inst_sw=(mem_aluop_i == 8'h9A);
    wire inst_sh=(mem_aluop_i == 8'h99);
    wire inst_lbu=(mem_aluop_i == 8'h91);
    wire inst_lh=(mem_aluop_i == 8'h93);
    wire inst_lhu=(mem_aluop_i == 8'h94);
       
    // 获得数据存储器读字节使能信号
    assign daddr  =  mem_wd_i;

    //note that the little endian
    assign dre[3] = 
                    ((inst_lb &(daddr[1:0]==2'b00))|
                     (inst_lbu &(daddr[1:0]==2'b00))|
                      (inst_lh &(daddr[1:0]==2'b00))|
                      (inst_lhu &(daddr[1:0]==2'b00))|inst_lw);
    assign dre[2] = 
                    ((inst_lb &(daddr[1:0]==2'b01))|
                      (inst_lbu &(daddr[1:0]==2'b01))|
                       (inst_lh &(daddr[1:0]==2'b00))|
                       (inst_lhu &(daddr[1:0]==2'b00))|inst_lw);
    assign dre[1] =
                    ((inst_lb &(daddr[1:0]==2'b10))|
                     (inst_lbu &(daddr[1:0]==2'b10))|
                      (inst_lh &(daddr[1:0]==2'b10))|
                      (inst_lhu &(daddr[1:0]==2'b10))|inst_lw);
    assign dre[0] =
                    ((inst_lb &(daddr[1:0]==2'b11))|
                     (inst_lbu &(daddr[1:0]==2'b11))|
                      (inst_lh &(daddr[1:0]==2'b10))|
                      (inst_lhu &(daddr[1:0]==2'b10))|inst_lw);
    
    // 获得数据存储器使能信�?
    assign dce = (inst_lb|inst_lw|inst_sb|inst_sw|
                                                     inst_lbu|inst_lh|inst_lhu|inst_sh);
    
    // 获得数据存储器写字节使能信号
    assign we[3] = 
                    ((inst_sb &(daddr[1:0]==2'b00))|
                     (inst_sh &(daddr[1:0]==2'b00))|inst_sw);
    assign we[2] = 
                    ((inst_sb &(daddr[1:0]==2'b01))|
                     (inst_sh &(daddr[1:0]==2'b00))|inst_sw);
    assign we[1] = 
                    ((inst_sb &(daddr[1:0]==2'b10))|
                     (inst_sh &(daddr[1:0]==2'b10))|inst_sw);
    assign we[0] =
                    ((inst_sb &(daddr[1:0]==2'b11))|
                     (inst_sh &(daddr[1:0]==2'b10))|inst_sw);
    
    // 确定待写入数据存储器的数�?
    wire[`WORD_BUS] din_reverse = {mem_din_i[7:0],mem_din_i[15:8],mem_din_i[23:16],mem_din_i[31:24]};
    wire[`WORD_BUS] din_byte = {mem_din_i[7:0],mem_din_i[7:0],mem_din_i[7:0],mem_din_i[7:0]};
    wire[`WORD_BUS] din_half = {mem_din_i[7:0],mem_din_i[15:8],mem_din_i[7:0],mem_din_i[15:8]};
    assign din = 
                 (we == 4'b1111 )?din_reverse:
                 (we == 4'b1000 )?din_byte:
                 (we == 4'b0100 )?din_byte:
                 (we == 4'b0010 )?din_byte:
                 (we == 4'b0001 )?din_byte:
                 (we == 4'b0011 )?din_half:
                 (we == 4'b1100 )?din_half:`ZERO_WORD;
endmodule