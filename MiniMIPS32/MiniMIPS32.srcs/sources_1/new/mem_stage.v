`include "defines.v"
//add the output port  mem_aluop_o,which is transmitted to the stage wb,used to distinguish the inst
//L__and inst S__
 module mem_stage (

    //input from exe stage
    input  wire [`ALUOP_BUS     ]       mem_aluop_i,
    input  wire [`REG_ADDR_BUS  ]       mem_wa_i,
    input  wire                         mem_wreg_i,
    input  wire [`REG_BUS       ]       mem_wd_i,
    input  wire                         mem_mreg_i,
    input  wire [`REG_BUS       ]       mem_din_i,
    input  wire [`WE_HILO]              mem_whilo_i,
    input  wire [`DOUBLE_REG_BUS]       mem_hilo_i,

    input wire                          cp0_we_i,
    input wire [`REG_ADDR_BUS       ]   cp0_waddr_i,
    input wire [`REG_BUS            ]   cp0_wdata_i,
    input wire                          wb2mem_cp0_we,
    input wire [`REG_ADDR_BUS       ]   wb2mem_cp0_wa,
    input wire [`REG_BUS            ]   wb2mem_cp0_wd,

    input wire [`INST_ADDR_BUS      ]   mem_pc_i,
    input wire                          mem_in_delay_i,
    input wire [`EXC_CODE_BUS       ]   mem_exccode_i,

    input wire [`WORD_BUS           ]   cp0_status,
    input wire [`WORD_BUS           ]   cp0_cause,

    // to wb
    output wire [`REG_ADDR_BUS  ]       mem_wa_o,
    output wire                         mem_wreg_o,
    output wire [`REG_BUS       ]       mem_dreg_o,
    output wire                         mem_mreg_o,
    output wire [`BSEL_BUS      ]       dre,
    output wire [`WE_HILO]              mem_whilo_o,
    output wire [`DOUBLE_REG_BUS]       mem_hilo_o,

    // to mem
    output wire                         dce,
    output wire [`INST_ADDR_BUS ]       daddr,
    output wire [`BSEL_BUS      ]       we,
    output wire [`REG_BUS       ]       din,
    output wire [`ALUOP_BUS     ]       mem_aluop_o,

    output wire                         cp0_we_o,
    output wire [`REG_ADDR_BUS      ]   cp0_waddr_o,
    output wire [`REG_BUS           ]   cp0_wdata_o,

    output wire [`INST_ADDR_BUS     ]   cp0_pc,
    output wire                         cp0_in_delay,
    output wire [`EXC_CODE_BUS      ]   cp0_exccode
    );

    wire [`WORD_BUS]    status;
    wire [`WORD_BUS]    cause;

    assign mem_wa_o    = mem_wa_i;
    assign mem_wreg_o  = mem_wreg_i;
    assign mem_dreg_o  = mem_wd_i;
    assign mem_whilo_o = mem_whilo_i;
    assign mem_hilo_o  = mem_hilo_i;
    assign mem_mreg_o  = mem_mreg_i;
    assign mem_aluop_o = mem_aluop_i;

    wire inst_lb  = (mem_aluop_i == 8'h90);
    wire inst_lw  = (mem_aluop_i == 8'h92);
    wire inst_sb  = (mem_aluop_i == 8'h98);
    wire inst_sw  = (mem_aluop_i == 8'h9A);
    wire inst_sh  = (mem_aluop_i == 8'h99);
    wire inst_lbu = (mem_aluop_i == 8'h91);
    wire inst_lh  = (mem_aluop_i == 8'h93);
    wire inst_lhu = (mem_aluop_i == 8'h94);

    // memory address to read
    assign daddr  =  mem_wd_i;

    assign cp0_we_o = (cpu_rst_n == `RST_ENABLE) ? 1'b0:cp0_we_i;
    assign cp0_waddr_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : cp0_waddr_i;
    assign cp0_wdata_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :cp0_wdata_i;

    assign status = (wb2mem_cp0_we==`WRITE_ENABLE && wb2mem_cp0_wa == `CP0_STATUS) ? wb2mem_cp0_wd : cp0_status;
    assign cause = (wb2mem_cp0_we == `WRITE_ENABLE && wb2mem_cp0_wa  == `CP0_CAUSE) ? wb2mem_cp0_wd : cp0_cause;
    
    assign cp0_in_delay = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : mem_in_delay_i;
    assign cp0_pc = (cpu_rst_n == `RST_ENABLE) ? `PC_INIT : mem_pc_i;
    
    assign cp0_exccode = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD:
                         ((status[15:10] & cause[15:10]) != 8'h00 && status[1] == 1'b0 && status[0] == 1'b1) ? `EXC_INT:
                         mem_exccode_i;
    //decide byte-read enable signal
    assign dre[3] =
                    ((inst_lb  &(daddr[1:0] == 2'b00))|
                     (inst_lbu &(daddr[1:0] == 2'b00))|
                     (inst_lh  &(daddr[1:0] == 2'b00))|
                     (inst_lhu &(daddr[1:0] == 2'b00))|inst_lw);
    assign dre[2] =
                    ((inst_lb  &(daddr[1:0] == 2'b01))|
                     (inst_lbu &(daddr[1:0] == 2'b01))|
                     (inst_lh  &(daddr[1:0] == 2'b00))|
                     (inst_lhu &(daddr[1:0] == 2'b00))|inst_lw);
    assign dre[1] =
                    ((inst_lb  &(daddr[1:0] == 2'b10))|
                     (inst_lbu &(daddr[1:0] == 2'b10))|
                     (inst_lh  &(daddr[1:0] == 2'b10))|
                     (inst_lhu &(daddr[1:0] == 2'b10))|inst_lw);
    assign dre[0] =
                    ((inst_lb  &(daddr[1:0] == 2'b11))|
                     (inst_lbu &(daddr[1:0] == 2'b11))|
                     (inst_lh  &(daddr[1:0] == 2'b10))|
                     (inst_lhu &(daddr[1:0] == 2'b10))|inst_lw);

    // enable memory
    assign dce = (inst_lb|inst_lw|inst_sb|inst_sw|inst_lbu|inst_lh|inst_lhu|inst_sh);

    // decide byte-write enable
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

    //reverse data into little endian
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
