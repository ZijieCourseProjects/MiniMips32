`include "defines.v"

module wb_stage(
    input  wire                   wb_mreg_i,
    input  wire [`BSEL_BUS      ] wb_dre_i,
	input  wire [`REG_ADDR_BUS  ] wb_wa_i,
	input  wire                   wb_wreg_i,
	input  wire [`REG_BUS       ] wb_dreg_i,
    input  wire [`WE_HILO]        wb_whilo_i,
    input  wire [`DOUBLE_REG_BUS] wb_hilo_i,
    input  wire [`ALUOP_BUS     ]   wb_aluop_i,

    // data from memory
    input  wire [`WORD_BUS] dm,

    // data to write back
    output wire [`REG_ADDR_BUS  ] wb_wa_o,
	output wire                   wb_wreg_o,
    output wire [`WORD_BUS      ] wb_wd_o,
    output wire [`WE_HILO]        wb_whilo_o,
    output wire [`DOUBLE_REG_BUS] wb_hilo_o,


    input wire                      cp0_we_i,
    input wire [`REG_ADDR_BUS   ]   cp0_waddr_i,
    input wire [`REG_BUS        ]   cp0_wdata_i,
    
    output wire                     cp0_we_o,
    output wire [`REG_ADDR_BUS  ]   cp0_waddr_o,
    output wire [`REG_BUS       ]   cp0_wdata_o
    );

    
    assign cp0_we_o = cp0_we_i;
    assign cp0_waddr_o = cp0_waddr_i;
    assign cp0_wdata_o = cp0_wdata_i;

    // write back to general register file and HILO register
    assign wb_wa_o      = wb_wa_i;
    assign wb_wreg_o    = wb_wreg_i;
    assign wb_whilo_o   = wb_whilo_i;
    assign wb_hilo_o    = wb_hilo_i;

    //Select the corresponding word from the data read from the data memory according to the read byte enable signal
    wire [`WORD_BUS] data =
                            (wb_dre_i==4'b1111)?{dm[7:0],dm[15:8],dm[23:16],dm[31:24]}:
                            (wb_dre_i==4'b1000 && wb_aluop_i==`MINIMIPS32_LB  )?{{24{dm[31]}},dm[31:24]}:
                            (wb_dre_i==4'b0100 && wb_aluop_i==`MINIMIPS32_LB)?{{24{dm[23]}},dm[23:16]}:
                            (wb_dre_i==4'b0010 && wb_aluop_i==`MINIMIPS32_LB)?{{24{dm[15]}},dm[15:8]}:
                            (wb_dre_i==4'b0001 && wb_aluop_i==`MINIMIPS32_LB)?{{24{dm[7]}},dm[7:0]}:
                            (wb_dre_i==4'b0001 && wb_aluop_i==`MINIMIPS32_LBU)?{24'b0,dm[7:0]}:
                            (wb_dre_i==4'b0010 && wb_aluop_i==`MINIMIPS32_LBU)?{24'b0,dm[15:8]}:
                            (wb_dre_i==4'b0100 && wb_aluop_i==`MINIMIPS32_LBU)?{24'b0,dm[23:16]}:
                            (wb_dre_i==4'b1000 && wb_aluop_i==`MINIMIPS32_LBU)?{24'b0,dm[31:24]}:
                            (wb_dre_i==4'b0011 && wb_aluop_i==`MINIMIPS32_LH)?{{24{dm[7]}},dm[7:0],dm[15:8]}:
                            (wb_dre_i==4'b1100 && wb_aluop_i==`MINIMIPS32_LH)?{{24{dm[23]}},dm[23:16],dm[31:24]}:
                            (wb_dre_i==4'b0011 && wb_aluop_i==`MINIMIPS32_LHU)?{16'b0,dm[7:0],dm[15:8]}:
                            (wb_dre_i==4'b1100 && wb_aluop_i==`MINIMIPS32_LHU)?{16'b0,dm[23:16],dm[31:24]}:`ZERO_WORD;

    //Select the data to be written to the general register file according to the memory to register enable signal mreg
    assign wb_wd_o      =   (wb_mreg_i==`MREG_ENABLE)? data: wb_dreg_i;

endmodule
