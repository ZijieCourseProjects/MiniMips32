`include "defines.v"

module MiniMIPS32(
    input  wire                  cpu_clk_50M,
    input  wire                  cpu_rst_n,
    input wire [`CP0_INT_BUS] int,

    // inst_rom
    output wire [`INST_ADDR_BUS] iaddr,
    output wire                  ice,
    input  wire [`INST_BUS]      inst,

    output wire                  dce,
    output wire [`INST_ADDR_BUS] daddr,
    output wire [`BSEL_BUS]      we,
    output wire [`INST_BUS]      din,
    input  wire [`INST_BUS]      dm
    );

    wire [`WORD_BUS      ] pc;

    // wire between ifid_reg and id
    wire [`WORD_BUS      ] id_pc_i;

    // wire between id and regfile
    wire [`REG_ADDR_BUS  ] ra1;
    wire [`REG_BUS       ] rd1;
    wire [`REG_ADDR_BUS  ] ra2;
    wire [`REG_BUS       ] rd2;

    wire [`ALUOP_BUS     ] id_aluop_o;
    wire [`ALUTYPE_BUS   ] id_alutype_o;
    wire [`REG_BUS 	     ] id_src1_o;
    wire [`REG_BUS 	     ] id_src2_o;
    wire 				   id_wreg_o;
    wire [`REG_ADDR_BUS  ] id_wa_o;
    wire [`WE_HILO]        id_whilo_o;
    wire                   id_mreg_o;
    wire [`REG_BUS]        id_din_o;

    wire [`ALUOP_BUS     ] exe_aluop_i;
    wire [`ALUTYPE_BUS   ] exe_alutype_i;
    wire [`REG_BUS 	     ] exe_src1_i;
    wire [`REG_BUS 	     ] exe_src2_i;
    wire 				   exe_wreg_i;
    wire [`REG_ADDR_BUS  ] exe_wa_i;
    wire [`WE_HILO]        exe_whilo_i;
    wire                   exe_mreg_i;
    wire [`REG_BUS]        exe_din_i;


    wire [`REG_BUS 	     ] exe_hi_i;
    wire [`REG_BUS 	     ] exe_lo_i;

    wire [`ALUOP_BUS     ] exe_aluop_o;
    wire 				   exe_wreg_o;
    wire [`REG_ADDR_BUS  ] exe_wa_o;
    wire [`REG_BUS 	     ] exe_wd_o;
    wire                   exe_mreg_o;
    wire [`REG_BUS       ] exe_din_o;
    wire [`WE_HILO]        exe_whilo_o;
    wire [`DOUBLE_REG_BUS] exe_hilo_o;

    wire [`ALUOP_BUS     ] mem_aluop_i;
    wire 				   mem_wreg_i;
    wire [`REG_ADDR_BUS  ] mem_wa_i;
    wire [`REG_BUS 	     ] mem_wd_i;
    wire                   mem_mreg_i;
    wire [`REG_BUS       ] mem_din_i;
    wire [`WE_HILO]        mem_whilo_i;
    wire [`DOUBLE_REG_BUS] mem_hilo_i;

    wire 				   mem_wreg_o;
    wire [`REG_ADDR_BUS  ] mem_wa_o;
    wire [`REG_BUS 	     ] mem_dreg_o;
    wire                   mem_mreg_o;
    wire [`REG_BUS       ] mem_dre_o;
    wire [`WE_HILO]        mem_whilo_o;
    wire [`DOUBLE_REG_BUS] mem_hilo_o;
    wire [`ALUOP_BUS     ] mem_aluop_o;


    wire 				   wb_wreg_i;
    wire [`REG_ADDR_BUS  ] wb_wa_i;
    wire [`REG_BUS       ] wb_dreg_i;
    wire [`BSEL_BUS]       wb_dre_i;
    wire                   wb_mreg_i;
    wire [`WE_HILO]        wb_whilo_i;
    wire [`DOUBLE_REG_BUS] wb_hilo_i;
    wire [`ALUOP_BUS     ] wb_aluop_i;

    wire 				   wb_wreg_o;
    wire [`REG_ADDR_BUS  ] wb_wa_o;
    wire [`REG_BUS       ] wb_wd_o;

    wire [`WE_HILO]        wb_whilo_o;
    wire [`DOUBLE_REG_BUS] wb_hilo_o;
    wire [`INST_ADDR_BUS]  jump_addr_1;
    wire [`INST_ADDR_BUS]  jump_addr_2;
    wire [`INST_ADDR_BUS]  jump_addr_3;
    wire [`JTSEL_BUS]      jtsel;
    wire [`INST_ADDR_BUS]  if_pc_plus_4;
    wire [`INST_ADDR_BUS]  id_pc_plus_4;
    wire [`INST_ADDR_BUS]  id_ret_addr;
    wire [`INST_ADDR_BUS]  exe_ret_addr;
    
    //pipeline stall 
    wire[`STALL_BUS]      stall;
    wire                  stallreq_id;
    wire                  stallreq_exe;


    //exception handle
    wire [`EXC_CODE_BUS]     if_exccode_o;
    wire [`EXC_CODE_BUS]     id_exccode;
            
    
    wire [`REG_ADDR_BUS]     cp0_addr;
    wire [`INST_ADDR_BUS]    id_pc_o;
    wire                     id_in_delay_o;
    wire                     next_delay_o;
    wire [`EXC_CODE_BUS]     id_exccode_o;
    
    wire  [`REG_ADDR_BUS]     exe_cp0_addr;
    wire  [`INST_ADDR_BUS]    exe_pc;
    wire                      exe_in_delay;
    wire                     next_delay_o2;
    wire  [`EXC_CODE_BUS]    exe_exccode;
    
    wire                     cp0_re_o;
    wire [`REG_ADDR_BUS]     cp0_raddr_o;
    wire                     cp0_we_o;
    wire [`REG_ADDR_BUS]     cp0_waddr_o;
    wire [`REG_BUS]          cp0_wdata_o;

    wire [`INST_ADDR_BUS]     exe_pc_o;
    wire                      exe_in_delay_o;
    wire [`EXC_CODE_BUS]      exe_exccode_o;
    
    wire                  mem_cp0_we;
    wire [`REG_ADDR_BUS ] mem_cp0_waddr;
    wire [`REG_BUS      ] mem_cp0_wdata;
     
    wire [`INST_ADDR_BUS] mem_pc;
    wire                  mem_in_delay;
    wire [`EXC_CODE_BUS ] mem_exccode;
     
    wire                         cp0_we_o2;
    wire [`REG_ADDR_BUS      ]   cp0_waddr_o2;
    wire [`REG_BUS           ]   cp0_wdata_o2;
     
    wire [`INST_ADDR_BUS     ]   cp0_pc;
    wire                         cp0_in_delay;
    wire [`EXC_CODE_BUS      ]   cp0_exccode;
    
    wire                     wb_cp0_we;
    wire [`REG_ADDR_BUS  ]   wb_cp0_waddr;
    wire [`REG_BUS       ]   wb_cp0_wdata;
     
    wire                     cp0_we_o3;
    wire [`REG_ADDR_BUS  ]   cp0_waddr_o3;
    wire [`REG_BUS       ]   cp0_wdata_o3;
     
    wire                 flush;
    wire                 flush_im;
    wire [`REG_BUS     ] cp0_excaddr;
     
    wire [`REG_BUS     ] data_o;
    wire [`REG_BUS     ] status_o;
    wire [`REG_BUS     ] cause_o;
    wire [`REG_BUS     ] eaddr;

    if_stage if_stage0(.cpu_clk_50M(cpu_clk_50M), .cpu_rst_n(cpu_rst_n),
        .pc(pc), .ice(ice), .iaddr(iaddr),.jump_addr_1(jump_addr_1),
        .jump_addr_2(jump_addr_2),.jump_addr_3(jump_addr_3),.jtsel(jtsel),
        .pc_plus_4(if_pc_plus_4), .stall(stall), 
        .flush(flush),.cp0_excaddr(cp0_excaddr),.if_exccode_o(if_exccode_o)
    );

    ifid_reg ifid_reg0(.cpu_clk_50M(cpu_clk_50M), .cpu_rst_n(cpu_rst_n),
        .if_pc(pc), .id_pc(id_pc_i),.if_pc_plus_4(if_pc_plus_4),
        .id_pc_plus_4(id_pc_plus_4),.stall(stall),.flush(flush),
        .if_exccode(if_exccode_o),.id_exccode(id_exccode)
    );

    id_stage id_stage0(.id_pc_i(id_pc_i), 
        .id_inst_i(inst),
        .rd1(rd1), .rd2(rd2),	  
        .ra1(ra1), .ra2(ra2), 
        .exe2id_wreg(exe_wreg_o),
        .exe2id_wa(exe_wa_o),
        .exe2id_wd(exe_wd_o),
        .mem2id_wreg(mem_wreg_o),
        .mem2id_wa(mem_wa_o),
        .mem2id_wd(mem_dreg_o),
        .id_aluop_o(id_aluop_o), .id_alutype_o(id_alutype_o),
        .id_src1_o(id_src1_o), .id_src2_o(id_src2_o),
        .id_wa_o(id_wa_o), .id_wreg_o(id_wreg_o),
        .id_whilo_o(id_whilo_o),
        .id_mreg_o(id_mreg_o),.id_din_o(id_din_o),
        .pc_plus_4(id_pc_plus_4),
        .jump_addr_1(jump_addr_1),
        .jump_addr_2(jump_addr_2),
        .jump_addr_3(jump_addr_3),
        .jtsel(jtsel),
        .ret_addr( id_ret_addr),
        .stallreq_id( stallreq_id),.exe2id_mreg(exe_mreg_o),.mem2id_mreg(mem_mreg_o),
        .id_in_delay_i(next_delay_o2),.flush_im(flush_im),
        .id_exccode_o(id_exccode_o),.id_pc_o(id_pc_o),
        .next_delay_o(next_delay_o),.cp0_addr(cp0_addr),.id_in_delay_o(id_in_delay_o),
        .id_exccode_i(id_exccode)
    );

    regfile regfile0(.cpu_clk_50M(cpu_clk_50M), .cpu_rst_n(cpu_rst_n),
        .we(wb_wreg_o), .wa(wb_wa_o), .wd(wb_wd_o),
        .ra1(ra1), .rd1(rd1),
        .ra2(ra2), .rd2(rd2)
    );

    idexe_reg idexe_reg0(
        .cpu_clk_50M(cpu_clk_50M), .cpu_rst_n(cpu_rst_n), 
        .id_alutype(id_alutype_o), .id_aluop(id_aluop_o),
        .id_src1(id_src1_o), .id_src2(id_src2_o),
        .id_wa(id_wa_o), .id_wreg(id_wreg_o),.id_whilo(id_whilo_o),
        .id_mreg(id_mreg_o),.id_din(id_din_o),
        .exe_alutype(exe_alutype_i), .exe_aluop(exe_aluop_i),
        .exe_src1(exe_src1_i), .exe_src2(exe_src2_i), 
        .exe_wa(exe_wa_i), .exe_wreg(exe_wreg_i),.exe_whilo(exe_whilo_i),
        .exe_mreg(exe_mreg_i),.exe_din(exe_din_i),
        .id_ret_addr(id_ret_addr),.exe_ret_addr(exe_ret_addr),
        .stall(stall),
        .id_exccode(id_exccode_o),.id_pc(id_pc_o),.next_delay_i(next_delay_o),
        .id_cp0_addr(cp0_addr),.id_in_delay(id_in_delay_o),.flush(flush),
        .exe_exccode(exe_exccode),.exe_pc(exe_pc),.next_delay_o(next_delay_o2),
        .exe_cp0_addr(exe_cp0_addr),.exe_in_delay(exe_in_delay)

    );

    exe_stage exe_stage0(
        .cpu_clk_50M(cpu_clk_50M),
        .exe_alutype_i(exe_alutype_i), .exe_aluop_i(exe_aluop_i),
        .exe_src1_i(exe_src1_i), .exe_src2_i(exe_src2_i),
        .exe_wa_i(exe_wa_i), .exe_wreg_i(exe_wreg_i),
        .exe_mreg_i(exe_mreg_i),.exe_din_i(exe_din_i),
        .hi_i(exe_hi_i),.lo_i(exe_lo_i),.exe_whilo_i(exe_whilo_i),
        .mem2exe_whilo(mem_whilo_o),.mem2exe_hilo(mem_hilo_o),
        .wb2exe_whilo(wb_whilo_o),.wb2exe_hilo(wb_hilo_o),
        .ret_addr(exe_ret_addr),
        
        .exe_aluop_o(exe_aluop_o),
        .exe_wa_o(exe_wa_o), .exe_wreg_o(exe_wreg_o), .exe_wd_o(exe_wd_o),
        .exe_mreg_o(exe_mreg_o),.exe_din_o(exe_din_o),
        .exe_whilo_o(exe_whilo_o),.exe_hilo_o(exe_hilo_o),
        
        .stallreq_exe(stallreq_exe),
        .mem2exe_cp0_we(cp0_we_o2),.mem2exe_cp0_wa(cp0_waddr_o2),.mem2exe_cp0_wd(cp0_wdata_o2),
        .wb2exe_cp0_we(cp0_we_o3),.wb2exe_cp0_wa(cp0_waddr_o3),.wb2exe_cp0_wd(cp0_wdata_o3),
        .exe_exccode_i(exe_exccode),.exe_pc_i(exe_pc),.cp0_data_i(data_o),.cp0_addr_i(exe_cp0_addr),
        .exe_in_delay_i(exe_in_delay),.exe_exccode_o(exe_exccode_o),.exe_pc_o(exe_pc_o),
        .exe_in_delay_o(exe_in_delay_o),.cp0_re_o(cp0_re_o),.cp0_raddr_o(cp0_raddr_o),
        .cp0_wdata_o(cp0_wdata_o),.cp0_we_o(cp0_we_o),.cp0_waddr_o(cp0_waddr_o)
    );

    exemem_reg exemem_reg0(.cpu_clk_50M(cpu_clk_50M), .cpu_rst_n(cpu_rst_n),
        .exe_aluop(exe_aluop_o),
        .exe_wa(exe_wa_o), .exe_wreg(exe_wreg_o), .exe_wd(exe_wd_o),
        .exe_mreg(exe_mreg_o),.exe_din(exe_din_o),
        .exe_whilo(exe_whilo_o),.exe_hilo(exe_hilo_o),
        .mem_aluop(mem_aluop_i),
        .mem_wa(mem_wa_i), .mem_wreg(mem_wreg_i), .mem_wd(mem_wd_i),
        .mem_mreg(mem_mreg_i),.mem_din(mem_din_i),
        .mem_whilo(mem_whilo_i),.mem_hilo(mem_hilo_i),.stall(stall),
        .exe_exccode(exe_exccode_o),.exe_pc(exe_pc_o),.exe_in_delay(exe_in_delay_o),
        .exe_cp0_we(cp0_we_o),.exe_cp0_waddr(cp0_waddr_o),.exe_cp0_wdata(cp0_wdata_o),
        .flush(flush),.mem_exccode(mem_exccode),.mem_pc(mem_pc),.mem_in_delay(mem_in_delay),
        .mem_cp0_we(mem_cp0_we),.mem_cp0_waddr(mem_cp0_waddr),.mem_cp0_wdata(mem_cp0_wdata)
    );

    mem_stage mem_stage0(
       .mem_aluop_i(mem_aluop_i),
        .mem_wa_i(mem_wa_i), .mem_wreg_i(mem_wreg_i), .mem_wd_i(mem_wd_i),
        .mem_mreg_i(mem_mreg_i),.mem_din_i(mem_din_i),
        .mem_whilo_i(mem_whilo_i),.mem_hilo_i(mem_hilo_i),
        .mem_wa_o(mem_wa_o), .mem_wreg_o(mem_wreg_o), .mem_dreg_o(mem_dreg_o),
        .mem_mreg_o(mem_mreg_o),.dre(mem_dre_o),
        .mem_whilo_o(mem_whilo_o),.mem_hilo_o(mem_hilo_o),
        .dce(dce),.daddr(daddr),.we(we),.din(din),
        .mem_aluop_o(mem_aluop_o),
        .mem_exccode_i(mem_exccode),.mem_pc_i(mem_pc),.mem_in_delay_i(mem_in_delay),
        .cp0_we_i(mem_cp0_we),.cp0_waddr_i(mem_cp0_waddr),.cp0_wdata_i(mem_cp0_wdata),
        .wb2mem_cp0_we(cp0_we_o3),.wb2mem_cp0_wa(cp0_waddr_o3),.wb2mem_cp0_wd(cp0_wdata_o3),
        .cp0_status(status_o),.cp0_cause(cause_o),.cp0_exccode(cp0_exccode),
        .cp0_pc(cp0_pc),.cp0_in_delay(cp0_in_delay),.cp0_we_o(cp0_we_o2),
        .cp0_waddr_o(cp0_waddr_o2),.cp0_wdata_o(cp0_wdata_o2),
        .cp0_eaddr(eaddr)
    );

    memwb_reg memwb_reg0(.cpu_clk_50M(cpu_clk_50M), .cpu_rst_n(cpu_rst_n),
        .mem_wa(mem_wa_o), .mem_wreg(mem_wreg_o), .mem_dreg(mem_dreg_o),
        .mem_mreg(mem_mreg_o),.mem_dre(mem_dre_o),
        .mem_whilo(mem_whilo_o),.mem_hilo(mem_hilo_o),.mem_aluop(mem_aluop_o),
        .wb_wa(wb_wa_i), .wb_wreg(wb_wreg_i), .wb_dreg(wb_dreg_i),
        .wb_mreg(wb_mreg_i),.wb_dre(wb_dre_i),
        .wb_whilo(wb_whilo_i),.wb_hilo(wb_hilo_i),.wb_aluop( wb_aluop_i),
        .mem_cp0_we(cp0_we_o2),.mem_cp0_waddr(cp0_waddr_o2),
        .mem_cp0_wdata(cp0_wdata_o2),.flush(flush),
        .wb_cp0_we(wb_cp0_we),.wb_cp0_waddr(wb_cp0_waddr),
        .wb_cp0_wdata(wb_cp0_wdata)
    );

    wb_stage wb_stage0(
        .wb_mreg_i(wb_mreg_i),.wb_dre_i(wb_dre_i),
        .wb_wa_i(wb_wa_i), .wb_wreg_i(wb_wreg_i), .wb_dreg_i(wb_dreg_i),
        .wb_whilo_i(wb_whilo_i),.wb_hilo_i(wb_hilo_i),.wb_aluop_i( wb_aluop_i),
        .dm(dm),
        .wb_wa_o(wb_wa_o), .wb_wreg_o(wb_wreg_o), .wb_wd_o(wb_wd_o),
        .wb_whilo_o(wb_whilo_o),.wb_hilo_o(wb_hilo_o),
        .cp0_we_i(wb_cp0_we),.cp0_waddr_i(wb_cp0_waddr),.cp0_wdata_i(wb_cp0_wdata),
        .cp0_we_o(cp0_we_o3),.cp0_waddr_o(cp0_waddr_o3),.cp0_wdata_o(cp0_wdata_o3)
    );

    hilo hilo0(
        .cpu_clk_50M(cpu_clk_50M),.cpu_rst_n(cpu_rst_n),
        .we(wb_whilo_o),
        .hi_i(wb_hilo_o[63:32]),.lo_i(wb_hilo_o[31:0]),
        .hi_o(exe_hi_i),.lo_o(exe_lo_i)
    );
    
    scu scu0(
        .cpu_rst_n(cpu_rst_n),.stallreq_id(stallreq_id),
        .stallreq_exe(stallreq_exe),.stall(stall)
    );

    cp0_reg cp0_reg0(
        .cpu_clk_50M(cpu_clk_50M), .cpu_rst_n(cpu_rst_n),
        .exccode_i(cp0_exccode),.pc_i(cp0_pc),.in_delay_i(cp0_in_delay),
        .re(cp0_re_o),.raddr(cp0_raddr_o),.we(cp0_we_o3),.waddr(cp0_waddr_o3),
        .wdata(cp0_wdata_o3),.int_i(int),.flush_im(flush_im),.cp0_excaddr(cp0_excaddr),
        .flush(flush),.data_o(data_o),.status_o(status_o),.cause_o(cause_o),
        .eaddr(eaddr)
    );
endmodule
