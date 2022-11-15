`include "defines.v"

module exemem_reg (
    input  wire 				cpu_clk_50M,
    input  wire 				cpu_rst_n,

    input  wire [`ALUOP_BUS   ]    exe_aluop,
    input  wire [`REG_ADDR_BUS]    exe_wa,
    input  wire                    exe_wreg,
    input  wire [`REG_BUS 	  ]    exe_wd,
    input  wire                    exe_mreg,
    input  wire [`REG_BUS]         exe_din,
    input  wire [`WE_HILO]         exe_whilo,
    input  wire [`DOUBLE_REG_BUS]  exe_hilo,
    
    output reg  [`ALUOP_BUS   ]     mem_aluop,
    output reg  [`REG_ADDR_BUS]     mem_wa,
    output reg                      mem_wreg,
    output reg  [`REG_BUS 	  ]     mem_wd,
    output reg                      mem_mreg,
    output reg  [`REG_BUS]          mem_din,
    output reg  [`WE_HILO]          mem_whilo,
    output reg  [`DOUBLE_REG_BUS]   mem_hilo
    );

    always @(posedge cpu_clk_50M) begin
    if (cpu_rst_n == `RST_ENABLE) begin
        mem_aluop              <= `MINIMIPS32_SLL;
        mem_wa 				   <= `REG_NOP;
        mem_wreg   			   <= `WRITE_DISABLE;
        mem_wd   			   <= `ZERO_WORD;
        mem_mreg               <= `WRITE_DISABLE;
        mem_din                <= `ZERO_WORD;
        mem_whilo              <= `WRITE_DISABLE;
        mem_hilo               <= `ZERO_DWORD;
    end
    else if(stall[3]==`STOP) begin
        mem_aluop              <= `MINIMIPS32_SLL;
        mem_wa                 <= `REG_NOP;
        mem_wreg               <= `WRITE_DISABLE;
        mem_wd                 <= `ZERO_WORD;
        mem_mreg               <= `WRITE_DISABLE;
        mem_din                <= `ZERO_WORD;
        mem_whilo              <= `WRITE_DISABLE;
        mem_hilo               <= `ZERO_DWORD;
        mem_cp0_we             <= 1'b0;
        mem_cp0_waddr          <= `ZERO_WORD;
        mem_cp0_wdata          <= `ZERO_WORD;
        mem_pc                 <= `PC_INIT;
        mem_in_delay           <= 1'b0;
        mem_exccode            <= `EXC_NONE;
    end    
    else if(stall[3]==`NOSTOP) begin
        mem_aluop              <= exe_aluop;
        mem_wa                 <= exe_wa;
        mem_wreg               <= exe_wreg;
        mem_wd                 <= exe_wd;
        mem_mreg               <= exe_mreg;
        mem_din                <= exe_din;
        mem_whilo              <= exe_whilo;
        mem_hilo               <= exe_hilo;
        mem_cp0_we             <= exe_cp0_we;
        mem_cp0_waddr          <= exe_cp0_waddr;
        mem_cp0_wdata          <= exe_cp0_wdata;
        mem_pc                 <= exe_pc;
        mem_in_delay           <= exe_in_delay;
        mem_exccode            <= exe_exccode;
    end
  end

endmodule