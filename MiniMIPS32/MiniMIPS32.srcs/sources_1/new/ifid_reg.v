`include "defines.v"

module ifid_reg (
	input  wire 						cpu_clk_50M,
	input  wire 						cpu_rst_n,

	input  wire [`INST_ADDR_BUS]       if_pc,
	input  wire [`INST_ADDR_BUS]       if_pc_plus_4,

	output reg  [`INST_ADDR_BUS]       id_pc,
	output reg  [`INST_ADDR_BUS]       id_pc_plus_4
	);

	always @(posedge cpu_clk_50M) begin
		if (cpu_rst_n == `RST_ENABLE) begin
			id_pc 	<= `PC_INIT;
			id_pc_plus_4 <= `ZERO_WORD;
		end
		else begin
			id_pc	<= if_pc;
			id_pc_plus_4 <= if_pc_plus_4;
		end
	end

endmodule
