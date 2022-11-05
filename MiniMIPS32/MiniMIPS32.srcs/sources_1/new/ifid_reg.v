`include "defines.v"

module ifid_reg (
	input  wire 						cpu_clk_50M,
	input  wire 						cpu_rst_n,

	input  wire [`INST_ADDR_BUS]       if_pc,

	output reg  [`INST_ADDR_BUS]       id_pc
	);

	always @(posedge cpu_clk_50M) begin
		if (cpu_rst_n == `RST_ENABLE) begin
			id_pc 	<= `PC_INIT;
		end
		else begin
			id_pc	<= if_pc;
		end
	end

endmodule
