`include "defines.v"

module id_stage(
    
    // PC value from instr_fection stage
    input wire cpu_rst_n,
    input  wire [`INST_ADDR_BUS]    id_pc_i,

    // instruction word from inst_rom
    input  wire [`INST_BUS     ]    id_inst_i,

    // data from GPR
    input  wire [`REG_BUS      ]    rd1,
    input  wire [`REG_BUS      ]    rd2,
      
    // Decode information to be used in execution stage
    output wire [`ALUTYPE_BUS  ]    id_alutype_o,
    output wire [`ALUOP_BUS    ]    id_aluop_o,
    output wire                     id_whilo_o,
    output wire                     id_mreg_o,
    output wire [`REG_ADDR_BUS ]    id_wa_o,
    output wire                     id_wreg_o,
    output wire [`WORD_BUS ]        id_din_o,

    // source oprand 1&2 to be used in execution stage
    output wire [`REG_BUS      ]    id_src1_o,
    output wire [`REG_BUS      ]    id_src2_o,
      
    // register address to register file
    output wire [`REG_ADDR_BUS ]    ra1,
    output wire [`REG_ADDR_BUS ]    ra2
    );
    
    // arrange the word in little edian
    wire [`INST_BUS] id_inst = {id_inst_i[7:0], id_inst_i[15:8], id_inst_i[23:16], id_inst_i[31:24]};

    // extract sections from the instruction
    wire [5 :0] op   = id_inst[31:26];
    wire [5 :0] func = id_inst[5 : 0];
    wire [4 :0] rd   = id_inst[15:11];
    wire [4 :0] rs   = id_inst[25:21];
    wire [4 :0] rt   = id_inst[20:16];
    wire [4 :0] sa   = id_inst[10: 6];
    wire [15:0] imm  = id_inst[15: 0]; 

    /*-------------------- First step of Decode: sepcific the instruction --------------------*/
    wire inst_reg  = ~|op;
    wire inst_add  = inst_reg& func[5]&~func[4]&~func[3]& ~func[2]&~func[1]&~func[0];
    wire inst_subu = inst_reg& func[5]&~func[4]&~func[3]& ~func[2]&func[1]&func[0];
    wire inst_slt =  inst_reg& func[5]&~func[4]&func[3]& ~func[2]&func[1]&~func[0];
    wire inst_and  = inst_reg& func[5]&~func[4]&~func[3]& func[2]&~func[1]&~func[0];
    wire inst_mult  = inst_reg&~func[5]&func[4]&func[3]&~func[2]&~func[1]&~func[0];
    wire inst_mfhi  = inst_reg&~func[5]&func[4]&~func[3]&~func[2]&~func[1]&~func[0];
    wire inst_mflo  = inst_reg&~func[5]&func[4]&~func[3]&~func[2]&func[1]&~func[0];
    
    wire inst_sll  = inst_reg&~func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0];  
    
    wire inst_ori  = ~op[5]&~op[4]&op[3]&op[2]&~op[1]&op[0];
    wire inst_lui= ~op[5]&~op[4]&op[3]&op[2]&op[1]&op[0];
    wire inst_addiu= ~op[5]&~op[4]&op[3]&~op[2]&~op[1]&op[0];
    wire inst_sltiu= ~op[5]&~op[4]&op[3]&~op[2]&op[1]&op[0];
    wire inst_lb= op[5]&~op[4]&~op[3]&~op[2]&~op[1]&~op[0];
    wire inst_lw= op[5]&~op[4]&~op[3]&~op[2]&op[1]&op[0];
    wire inst_sb= op[5]&~op[4]&op[3]&~op[2]&~op[1]&~op[0];
    wire inst_sw= op[5]&~op[4]&op[3]&~op[2]&op[1]&op[0];
    
    //Math
    wire inst_addu=inst_reg& func[5]&~func[4]&~func[3]& ~func[2]&~func[1]& func[0];
    wire inst_multu=inst_reg& ~func[5]& func[4]& func[3]& ~func[2]&~func[1]& func[0];
    wire inst_sub=inst_reg& func[5]& ~func[4]& ~func[3]& ~func[2]& func[1]& ~func[0];
    
    wire inst_addi=~op[5]&~op[4]&op[3]&~op[2]&~op[1]&~op[0];
    
    
    //shift
    wire inst_sra=inst_reg& ~func[5]& ~func[4]& ~func[3]& ~func[2]& func[1]& func[0];
    wire inst_srav=inst_reg& ~func[5]& ~func[4]& ~func[3]& func[2]& func[1]& func[0];
   
    /*------------------------------------------------------------------------------*/

    /*-------------------- Step2: generate sepcific controlling signal --------------------*/
    // operate_type
    assign id_alutype_o[2] = (cpu_rst_n==`RST_ENABLE)? 1'b0:
                              (inst_sll|inst_sra|inst_srav);
    assign id_alutype_o[1] = (cpu_rst_n==`RST_ENABLE)? 1'b0:
                             (inst_and|inst_mfhi|inst_mflo|inst_ori|inst_lui);
    assign id_alutype_o[0] = (cpu_rst_n==`RST_ENABLE)? 1'b0:
                             (inst_add|inst_subu|inst_slt|inst_mfhi|inst_mflo|
                               inst_addiu|inst_sltiu|inst_lb|inst_lw|inst_sb|inst_sw|inst_addu|
                               inst_addi|inst_sub);

    // OP-code
    assign id_aluop_o[7]   = (cpu_rst_n==`RST_ENABLE)? 1'b0:
                               (inst_lb|inst_lw|inst_sb|inst_sw);
    assign id_aluop_o[6]   = 1'b0;
    assign id_aluop_o[5]   =  (cpu_rst_n==`RST_ENABLE)? 1'b0:
                               (inst_slt|inst_sltiu);
    assign id_aluop_o[4]   = (cpu_rst_n==`RST_ENABLE)? 1'b0:
                             (inst_add|inst_subu|inst_and|inst_mult|inst_sll|
                               inst_ori|inst_addiu|inst_lb|inst_lw|inst_sb|inst_sw|inst_addu|
                               inst_addi|inst_multu|inst_sra|inst_srav|inst_sub);
                              
    assign id_aluop_o[3]   =(cpu_rst_n==`RST_ENABLE)? 1'b0:
                             (inst_add|inst_subu|inst_and|inst_mfhi|inst_mflo|
                               inst_ori|inst_addiu|inst_sb|inst_sw|inst_addi|inst_sub);
    assign id_aluop_o[2]   = (cpu_rst_n==`RST_ENABLE)? 1'b0:
                             (inst_slt|inst_and|inst_mult|inst_mfhi|inst_mflo|
                               inst_ori|inst_lui|inst_sltiu|inst_addu|inst_multu|inst_sub);
    assign id_aluop_o[1]   = (cpu_rst_n==`RST_ENABLE)? 1'b0:
                             (inst_subu|inst_slt|inst_sltiu|inst_lw|inst_sw|inst_addu|
                              inst_addi|inst_sra|inst_srav|inst_sub);
                             
    assign id_aluop_o[0]   = (cpu_rst_n==`RST_ENABLE)? 1'b0:
                             (inst_subu|inst_mflo|inst_sll|inst_ori|inst_lui|
                              inst_addiu|inst_sltiu|inst_addu|inst_multu|inst_sra);
 
    // enabling signal for GPRs
    assign id_wreg_o       = (cpu_rst_n==`RST_ENABLE)? 1'b0:
                             (inst_add|inst_subu|inst_slt|inst_and|inst_mfhi|
                               inst_mflo|inst_sll|inst_ori|inst_lui|inst_addiu|inst_sltiu| 
                               inst_lb|inst_lw|inst_addu|inst_addi|inst_sra|inst_srav|inst_sub);

    //enabling signal for writing hilo register
    assign id_whilo_o =(cpu_rst_n==`RST_ENABLE)? 1'b0:(inst_mult|inst_multu);
    
    // shift signal
    wire shift=inst_sll|inst_sra;
    
    //immediate number signal
    wire immsel=inst_ori|inst_lui|inst_addiu|inst_sltiu|inst_lb|inst_lw|inst_sb|inst_sw|
                 inst_addi;
    
    //destination register selection signal
    wire rtsel= inst_ori|inst_lui|inst_addiu|inst_sltiu|inst_lb|inst_lw|inst_addi;
    
    //Signed extension signal
    wire sext= inst_addiu|inst_sltiu|inst_lb|inst_lw|inst_sb|inst_sw|inst_addi;
    
    //signal for high semi-word signal
    wire upper=inst_lui;
    
    //memory to register signal
    assign id_mreg_o =(cpu_rst_n==`RST_ENABLE)? 1'b0:(inst_lb|inst_lw);
    
    //rs -> ra1 , rt -> ra2
    assign ra1 =(cpu_rst_n==`RST_ENABLE)? `ZERO_WORD:rs;
    assign ra2 =(cpu_rst_n==`RST_ENABLE)? `ZERO_WORD:rt;
    /*------------------------------------------------------------------------------*/
    //imm number for execute
    wire [31:0]imm_ext=(cpu_rst_n==`RST_ENABLE)? `ZERO_WORD:
                        (upper==`UPPER_ENABLE)?(imm<<16):
                        (sext==`SIGNED_EXT)?{{16{imm[15]}},imm}:{{16{1'b0}},imm};              
    // address of destination register to write
    assign id_wa_o      = (cpu_rst_n==`RST_ENABLE)?`ZERO_WORD:(rtsel==`RT_ENABLE)? rt:rd;
    
    //data to be written into the memory
    assign id_din_o=(cpu_rst_n==`RST_ENABLE)?`ZERO_WORD:rd2;

    // shift count if shift signal is active, else data from register port 1
    assign id_src1_o = (cpu_rst_n==`RST_ENABLE)?`ZERO_WORD:
                       (shift==`SHIFT_ENABLE)?{27'b0,sa}:rd1;

    // imm if imm signal is active, else the data from register port 2
    assign id_src2_o = (cpu_rst_n==`RST_ENABLE)?`ZERO_WORD:
                       (immsel==`IMM_ENABLE)?imm_ext:rd2;                  

endmodule
