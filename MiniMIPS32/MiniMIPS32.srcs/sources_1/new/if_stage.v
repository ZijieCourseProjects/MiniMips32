`include "defines.v"

module if_stage (
    input 	wire 					cpu_clk_50M,
    input 	wire 					cpu_rst_n,
    input 	wire [`INST_ADDR_BUS]	jump_addr_1,
    input 	wire [`INST_ADDR_BUS]	jump_addr_2,
    input 	wire [`INST_ADDR_BUS]	jump_addr_3,
    input   wire [`JTSEL_BUS]   	jtsel,
    input   wire [`STALL_BUS ]     stall,
    
    output 	wire [`INST_ADDR_BUS]	pc_plus_4,
    output  reg                     ice,
    output 	reg  [`INST_ADDR_BUS] 	pc,
    output 	wire [`INST_ADDR_BUS]	iaddr
    );
    
    assign pc_plus_4 = pc + 4;
    wire [`INST_ADDR_BUS] pc_next; 
    assign pc_next = (jtsel==2'b00)?pc_plus_4:
                     (jtsel==2'b01)?jump_addr_1:                    //J,JAR
                     (jtsel==2'b10)?jump_addr_3:                    //JR
                     (jtsel==2'b11)?jump_addr_2:`PC_INIT; 
    reg ce;
    always @(posedge cpu_clk_50M) begin
		if (cpu_rst_n == `RST_ENABLE) begin
			ce <= `CHIP_DISABLE;		      // disable INSTR MEM while resetting
		end else begin
			ce <= `CHIP_ENABLE; 		      // enable INSTR MEM after reseting
		end
	end
    assign ice=(stall[1]==`TRUE_V)? 0:ce;
    
    always @(posedge cpu_clk_50M) begin
        if (ce == `CHIP_DISABLE)
            pc <= `PC_INIT;                   // keep PC at the start of text segment while resetting
        else if(stall[0]==`NOSTOP) begin
            pc <= pc_next;                    // update PC register 
        end
    end
    
    assign iaddr = (ice == `CHIP_DISABLE) ? (`PC_INIT-`PC_INIT) : (pc);    //read instr memory with address from PC
endmodule