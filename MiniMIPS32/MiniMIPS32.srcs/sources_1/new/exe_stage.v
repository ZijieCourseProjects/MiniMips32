`include "defines.v"

module exe_stage (
    input  wire                     cpu_clk_50M,
    input  wire [`ALUTYPE_BUS	] 	  exe_alutype_i,
    input  wire [`ALUOP_BUS	  ] 	  exe_aluop_i,
    input  wire [`REG_BUS 		] 	  exe_src1_i,
    input  wire [`REG_BUS 		] 	  exe_src2_i,
    input  wire [`REG_ADDR_BUS] 	  exe_wa_i,
    input  wire 					          exe_wreg_i,
    input  wire                     exe_mreg_i,
    input  wire [`REG_BUS]          exe_din_i,
    input  wire [`WE_HILO]          exe_whilo_i,


    input  wire[`REG_BUS]           hi_i,
    input  wire[`REG_BUS]           lo_i,
    
    // Value of HILO registers obtained from MEM
    input  wire [`WE_HILO]          mem2exe_whilo,
    input  wire [`DOUBLE_REG_BUS]   mem2exe_hilo,
    
    // Value of HILO registers obtained from WB
    input  wire [`WE_HILO]          wb2exe_whilo,
    input  wire [`DOUBLE_REG_BUS]   wb2exe_hilo,

    input  wire [`INST_ADDR_BUS]    ret_addr,

    output wire [`ALUOP_BUS	    ] 	exe_aluop_o,
    output wire [`REG_ADDR_BUS 	] 	exe_wa_o,
    output wire 					          exe_wreg_o,
    output wire [`REG_BUS 		] 	  exe_wd_o,
    output wire                     exe_mreg_o,
    output wire [`REG_BUS]          exe_din_o,
    output wire [`WE_HILO]          exe_whilo_o,
    output wire [`DOUBLE_REG_BUS]   exe_hilo_o

    output wire                     stallreq_exe,
    );

    assign exe_aluop_o = exe_aluop_i;
    assign exe_mreg_o  = exe_mreg_i;
    assign exe_din_o   = exe_din_i;
    assign exe_whilo_o = exe_whilo_i;

    wire [`REG_BUS       ]             logicres;
    wire [`REG_BUS       ]             shiftres;
    wire [`REG_BUS       ]             moveres;
    wire [`REG_BUS       ]             hi_t;
    wire [`REG_BUS       ]             lo_t;
    wire [`REG_BUS       ]             arithres;
    wire [`REG_BUS       ]             memres;
    wire [`DOUBLE_REG_BUS       ]      mulres;
    reg  ['DOUBLE_REG_BUS]             divres;

    // CALCULATE LOGIC OPERATION
    assign logicres = (exe_aluop_i ==`MINIMIPS32_AND)   ? (exe_src1_i & exe_src2_i):
                      (exe_aluop_i ==`MINIMIPS32_ORI)   ? (exe_src1_i | exe_src2_i):
                      (exe_aluop_i ==`MINIMIPS32_LUI)   ? exe_src2_i :
                      (exe_aluop_i ==`MINIMIPS32_ANDI)  ? (exe_src1_i & exe_src2_i):
                      (exe_aluop_i ==`MINIMIPS32_NOR)   ? ~(exe_src1_i | exe_src2_i):
                      (exe_aluop_i ==`MINIMIPS32_OR)    ? (exe_src1_i | exe_src2_i):
                      (exe_aluop_i ==`MINIMIPS32_XOR)   ? (exe_src1_i ^ exe_src2_i):
                      (exe_aluop_i ==`MINIMIPS32_XORI)  ? (exe_src1_i ^ exe_src2_i):`ZERO_WORD;

    // CALCULATE SHIFT OPERATION
    wire signed [`REG_BUS       ] sra_res;
    assign sra_res  = (($signed(exe_src2_i)) >>> ($signed(exe_src1_i)));
    assign shiftres = (exe_aluop_i ==`MINIMIPS32_SLL)  ? (exe_src2_i <<exe_src1_i) :
                      (exe_aluop_i ==`MINIMIPS32_SRA)  ? sra_res:
                      (exe_aluop_i ==`MINIMIPS32_SRAV) ? sra_res:
                      (exe_aluop_i ==`MINIMIPS32_SLLV) ? (exe_src2_i <<exe_src1_i):
                      (exe_aluop_i ==`MINIMIPS32_SRLV) ? (exe_src2_i >>exe_src1_i):
                      (exe_aluop_i ==`MINIMIPS32_SRL)  ? (exe_src2_i >>exe_src1_i):`ZERO_WORD;

    //update high-low register value
    assign hi_t = (mem2exe_whilo[1] ==`WRITE_ENABLE)  ? mem2exe_hilo[63:32]:
                  (wb2exe_whilo[1]  == `WRITE_ENABLE) ? wb2exe_hilo[63:32] : hi_i;
    assign lo_t = (mem2exe_whilo[0] == `WRITE_ENABLE) ? mem2exe_hilo[31:0]:
                  (wb2exe_whilo[0]  == `WRITE_ENABLE) ? wb2exe_hilo[31:0] : lo_i;

    //move the value in two regs to destination register
    assign moveres = (exe_aluop_i == `MINIMIPS32_MFHI) ? hi_t:
                     (exe_aluop_i == `MINIMIPS32_MFLO) ? lo_t:`ZERO_WORD;

    //cauculate the arith instruction result.
    assign arithres = (exe_aluop_i ==`MINIMIPS32_ADD)    ? (exe_src1_i+exe_src2_i):
                       (exe_aluop_i ==`MINIMIPS32_LB)    ? (exe_src1_i+exe_src2_i):
                       (exe_aluop_i ==`MINIMIPS32_LW)    ? (exe_src1_i+exe_src2_i):
                       (exe_aluop_i ==`MINIMIPS32_LBU)   ? (exe_src1_i+exe_src2_i):
                       (exe_aluop_i ==`MINIMIPS32_LH)    ? (exe_src1_i+exe_src2_i):
                       (exe_aluop_i ==`MINIMIPS32_LHU)   ? (exe_src1_i+exe_src2_i):
                       (exe_aluop_i ==`MINIMIPS32_SB)    ? (exe_src1_i+exe_src2_i):
                       (exe_aluop_i ==`MINIMIPS32_SH)    ? (exe_src1_i+exe_src2_i):
                       (exe_aluop_i ==`MINIMIPS32_SW)    ? (exe_src1_i+exe_src2_i):
                       (exe_aluop_i ==`MINIMIPS32_ADDIU) ? (exe_src1_i+exe_src2_i):
                       (exe_aluop_i ==`MINIMIPS32_SUBU)  ? (exe_src1_i+(~exe_src2_i)+1):
                       (exe_aluop_i ==`MINIMIPS32_SLT)   ? (($signed(exe_src1_i) < $signed(exe_src2_i))? 32'b1:32'b0):
                       (exe_aluop_i ==`MINIMIPS32_SLTIU) ? ((exe_src1_i <exe_src2_i)? 32'b1:32'b0):
                       (exe_aluop_i ==`MINIMIPS32_ADDU)  ? (exe_src1_i+exe_src2_i):
                       (exe_aluop_i ==`MINIMIPS32_ADDI)  ? (exe_src1_i+exe_src2_i):
                       (exe_aluop_i ==`MINIMIPS32_SUB)   ?  (exe_src1_i-exe_src2_i):
                       (exe_aluop_i ==`MINIMIPS32_SLTI)  ? (($signed(exe_src1_i) < $signed(exe_src2_i))? 32'b1:32'b0):
                       (exe_aluop_i ==`MINIMIPS32_SLTU)  ? ((exe_src1_i <exe_src2_i)? 32'b1:32'b0):`ZERO_WORD;

    //result of signed multiply
    wire signed [`DOUBLE_REG_BUS] res1 = ($signed(exe_src1_i) * $signed(exe_src2_i));
    assign mulres = (exe_aluop_i ==`MINIMIPS32_MULT)        ?res1:
                    (exe_aluop_i ==`MINIMIPS32_MULTU)       ?(exe_src1_i * exe_src2_i):
                    (exe_aluop_i ==`MINIMIPS32_MTHI)        ? ({exe_src1_i,32'b0}):
                    (exe_aluop_i ==`MINIMIPS32_MTLO)        ? ({32'b0,exe_src1_i}):`ZERO_DWORD;

    assign exe_hilo_o = (exe_aluop_i ==`MINIMIPS32_MULT )  ? mulres :
                        (exe_aluop_i ==`MINIMIPS32_MULTU ) ? mulres :
                        (exe_aluop_i ==`MINIMIPS32_MTHI )  ? mulres :
                        (exe_aluop_i ==`MINIMIPS32_MTLO )  ? mulres :
                        (exe_aluop_i == `MINIMIPS32_DIV)   ? divres:
                        (exe_aluop_i == `MINIMIPS32_DIVU)  ? divres:`ZERO_DWORD;

    assign exe_wa_o   = exe_wa_i;
    assign exe_wreg_o = exe_wreg_i;

    // it could be either the data to be written to a register or the address of memory space to read in next stage.
    assign exe_wd_o = (exe_alutype_i == `LOGIC    )  ? logicres  :
                      (exe_alutype_i == `SHIFT    )  ? shiftres  :
                      (exe_alutype_i == `MOVE     )  ? moveres   :
                      (exe_alutype_i == `ARITH    )  ? arithres  :
                      (exe_alutype_i == `JUMP     )  ? ret_addr  :`ZERO_WORD;

    //division
    wire                        signed_div_i;
    wire [`REG_BUS       ]      div_opdata1;
    wire [`REG_BUS       ]      div_opdata2;
    wire                        div_start;
    reg                         div_ready;

    assign stallreq_exe =(cpu_rst_n ==`RST_ENABLE)? `NOSTOP:
                         ((exe_aluop_i==`MINIMIPS32_DIV) && (div_ready == `DIV_NOT_READY)) ?`STOP: 
                         ((exe_aluop_i==`MINIMIPS32_DIVU) && (div_ready == `DIV_NOT_READY)) ?`STOP:`NOSTOP;
    assign div_opdata1 =(cpu_rst_n ==`RST_ENABLE)? `ZERO_WORD:
                        (exe_aluop_i== `MINIMIPS32_DIV) ? exe_src1_i:
                        (exe_aluop_i== `MINIMIPS32_DIVU) ? exe_src1_i: `ZERO_WORD;
    assign div_opdata2=(cpu_rst_n == `RST_ENABLE)? `ZERO_WORD:
                       (exe_aluop_i== `MINIMIPS32_DIV)? exe_src2_i:
                       (exe_aluop_i== `MINIMIPS32_DIVU) ? exe_src2_i: `ZERO_WORD;
    assign div_start =(cpu_rst_n == `RST_ENABLE)?`DIV_STOP:
                      ((exe_aluop_i== `MINIMIPS32_DIV) &&(div_ready == `DIV_NOT_READY))?`DIV_START: 
                      ((exe_aluop_i== `MINIMIPS32_DIVU) &&(div_ready == `DIV_NOT_READY))?`DIV_START:`DIV_STOP;

    assign signed_div_i= (cpu_rst_n ==`RST_ENABLE)?1'b0:
                         (exe_aluop_i== `MINIMIPS32_DIV) ?1'b1: 1'b0;

    wire [34:0]         div_temp;
    wire [34:0]         div_temp0;
    wire [34:0]         div_temp1;
    wire [34:0]         div_temp2;
    wire [34:0]         div_temp3;
    wire [1:0]          mul_cnt;

    reg  [5: 0]         cnt;
    
    reg [65: 0]         dividend;
    reg [1: 0]          state;
    reg [33:0]          divisor;
    reg [31:0]          temp_op1;
    reg [31: 0]         temp_op2;
    
    wire [33: 0]        divisor_temp;
    wire [33: 0]        divisor2;
    wire [33: 0]        divisor3;

    assign divisor2  = divisor+divisor;
    assign divisor3  = divisor2+divisor;
    assign div_temp0 = {1'b000,dividend[63:32]}-{1'b000,`ZERO_WORD};
    assign div_temp1 = {1'b000,dividend[63:32]}-{1'b0,divisor};   
    assign div_temp2 = {1'b000,dividend[63:32]}-{1'b0,divisor2};  
    assign div_temp3 = {1'b000,dividend[63:32]}-{1'b0,divisor3};  

    assign div_temp =(div_temp3[34]== 1'b0 )? div_temp3:
                     (div_temp2[34] == 1'b0 )? div_temp2 : div_temp1;

    assign mul_cnt =(div_temp3[34] ==1'b0 )? 2'b11:
                    (div_temp2[34]==1'b0)? 2'b10:2'b01;

    always @(posedge cpu_clk_50M)begin
      if (cpu_rst_n ==`RST_ENABLE) begin
          state       <= `DIV_FREE;
          div_ready   <= `DIV_NOT_READY;
          divres      <=  {`ZERO_WORD, `ZERO_WORD};
      end 
      else begin
        case (state)
          `DIV_FREE:begin
            if(div_start == `DIV_START) begin
                if(div_opdata2 == `ZERO_WORD) begin 
                    state <= `DIV_BY_ZERO;
                end 
                else begin                      
                  state <= `DIV_ON;
                  cnt <= 6'b000000;
                  if(div_opdata1[31] == 1'b1 && signed_div_i) begin
                      temp_op1=~div_opdata1+1;    
                  end else begin
                      temp_op1 =div_opdata1;
                  end
                  if(div_opdata2[31]==1'b1 && signed_div_i) begin
                      temp_op2 =~div_opdata2+1;   
                  end else begin
                      temp_op2 =div_opdata2;
                  end
                  dividend <= {`ZERO_WORD, `ZERO_WORD};
                  dividend[31:0] <=temp_op1;
                  divisor  <= temp_op2;
                end
            end 
            else begin                    
              div_ready <= `DIV_NOT_READY;
              divres    <= {`ZERO_WORD,`ZERO_WORD};
            end 
          end            
          `DIV_BY_ZERO: begin          //DivByZero
            dividend <= {`ZERO_WORD, `ZERO_WORD};
            state    <= `DIV_END;
           end
          `DIV_ON: begin   //DivOn
            if(cnt!=6'b100010) begin 
              if(div_temp[34]==1'b1)begin
                  dividend <={dividend[63:0], 2'b00};
              end else begin
                  dividend <={div_temp[31:0], dividend[31:0], mul_cnt};
              end
              cnt <= cnt+2;
             end 
             else begin  
              if((div_opdata1[31]^div_opdata2[31])==1'b1 && signed_div_i) begin
                  dividend[31:0] <= (~dividend[31:0]+1); 
              end
              if((div_opdata1[31]^dividend[65])== 1'b1  && signed_div_i) begin
                  dividend[65: 34] <=(~dividend[65: 34]+1);
              end
              state <= `DIV_END; 
              cnt   <= 6'b000000; 
             end
          end
          
          `DIV_END: begin
            divres <={dividend[65: 34], dividend[31: 0]};
            div_ready <= `DIV_READY;
            if(div_start == `DIV_STOP) begin
                 state     <= `DIV_FREE;
                 div_ready <= `DIV_NOT_READY;
                 divres    <= {`ZERO_WORD, `ZERO_WORD};
            end
          end
        endcase
      end
    end

endmodule
