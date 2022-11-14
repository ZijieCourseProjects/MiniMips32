`include "defines.v"

module id_stage(

    // PC value from instr_fection stage
    input  wire [`INST_ADDR_BUS]    id_pc_i,

    // instruction word from inst_rom
    input  wire [`INST_BUS     ]    id_inst_i,

    // data from GPR
    input  wire [`REG_BUS      ]    rd1,
    input  wire [`REG_BUS      ]    rd2,
    
        //write enable from exe stage
    input wire                      exe2id_wreg,
    input wire [`REG_ADDR_BUS  ]    exe2id_wa,
    input wire [`INST_BUS      ]    exe2id_wd,
    
    //write enable from mem stage
    input wire                      mem2id_wreg,
    input wire [`REG_ADDR_BUS  ]    mem2id_wa,
    input wire [`INST_BUS      ]    mem2id_wd,
      
    // Decode information to be used in execution stage
    output wire [`ALUTYPE_BUS  ]    id_alutype_o,
    output wire [`ALUOP_BUS    ]    id_aluop_o,
    output wire [`WE_HILO]          id_whilo_o,
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
    wire [`INST_BUS] id_inst ={id_inst_i[7:0], id_inst_i[15:8], id_inst_i[23:16], id_inst_i[31:24]};

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
    wire inst_slt  = inst_reg& func[5]&~func[4]&func[3]& ~func[2]&func[1]&~func[0];
    wire inst_and  = inst_reg& func[5]&~func[4]&~func[3]& func[2]&~func[1]&~func[0];
    wire inst_mult = inst_reg&~func[5]&func[4]&func[3]&~func[2]&~func[1]&~func[0];
    wire inst_mfhi = inst_reg&~func[5]&func[4]&~func[3]&~func[2]&~func[1]&~func[0];
    wire inst_mflo = inst_reg&~func[5]&func[4]&~func[3]&~func[2]&func[1]&~func[0];

    wire inst_sll = inst_reg&~func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0];

    wire inst_ori   = ~op[5]&~op[4]&op[3]&op[2]&~op[1]&op[0];
    wire inst_lui   = ~op[5]&~op[4]&op[3]&op[2]&op[1]&op[0];
    wire inst_addiu = ~op[5]&~op[4]&op[3]&~op[2]&~op[1]&op[0];
    wire inst_sltiu = ~op[5]&~op[4]&op[3]&~op[2]&op[1]&op[0];
    wire inst_lb    = op[5]&~op[4]&~op[3]&~op[2]&~op[1]&~op[0];
    wire inst_lw    = op[5]&~op[4]&~op[3]&~op[2]&op[1]&op[0];
    wire inst_sb    = op[5]&~op[4]&op[3]&~op[2]&~op[1]&~op[0];
    wire inst_sw    = op[5]&~op[4]&op[3]&~op[2]&op[1]&op[0];

    //Math
    wire inst_addu  = inst_reg& func[5]&~func[4]&~func[3]& ~func[2]&~func[1]& func[0];
    wire inst_multu = inst_reg& ~func[5]& func[4]& func[3]& ~func[2]&~func[1]& func[0];
    wire inst_sub   = inst_reg& func[5]& ~func[4]& ~func[3]& ~func[2]& func[1]& ~func[0];
    wire inst_sltu  = inst_reg&func[5]& ~func[4]& func[3]& ~func[2]& func[1]& func[0];

    wire inst_addi = ~op[5]&~op[4]&op[3]&~op[2]&~op[1]&~op[0];
    wire inst_slti = ~op[5]&~op[4]&op[3]&~op[2]&op[1]&~op[0];

    //logic
    wire inst_nor  = inst_reg&func[5]&~func[4]&~func[3]&func[2]&func[1]&func[0];
    wire inst_or   = inst_reg&func[5]&~func[4]&~func[3]&func[2]&~func[1]&func[0];
    wire inst_xor  = inst_reg&func[5]&~func[4]&~func[3]&func[2]&func[1]&~func[0];
    wire inst_andi = ~op[5]&~op[4]&op[3]&op[2]&~op[1]&~op[0];

    wire inst_xori = ~op[5]&~op[4]&op[3]&op[2]&op[1]&~op[0];
    //shift
    wire inst_sra  = inst_reg & ~func[5] & ~func[4]& ~func[3]& ~func[2]& func[1]& func[0];
    wire inst_srav = inst_reg & ~func[5] & ~func[4]& ~func[3]& func[2]& func[1]& func[0];
    wire inst_sllv = inst_reg & ~func[5] & ~func[4]& ~func[3]& func[2]& ~func[1]& ~func[0];
    wire inst_srl  = inst_reg & ~func[5] & ~func[4]& ~func[3]& ~func[2]& func[1]& ~func[0];
    wire inst_srlv = inst_reg & ~func[5] & ~func[4]& ~func[3]& func[2]& func[1]& ~func[0];

    //hilo
    wire inst_mthi = inst_reg& ~func[5]& func[4]& ~func[3]& ~func[2]& ~func[1]& func[0];
    wire inst_mtlo = inst_reg& ~func[5]& func[4]& ~func[3]& ~func[2]& func[1]& func[0];

    //memory
    wire inst_lbu = op[5]&~op[4]&~op[3]& op[2]&~op[1]&~op[0];
    wire inst_lh  = op[5]&~op[4]&~op[3]& ~op[2]&~op[1]& op[0];
    wire inst_lhu = op[5]&~op[4]&~op[3]& op[2]&~op[1]& op[0];
    wire inst_sh  = op[5]&~op[4]& op[3]& ~op[2]&~op[1]& op[0];
    /*------------------------------------------------------------------------------*/

    /*-------------------- Step2: generate sepcific controlling signal --------------------*/
    // operate_type
    assign id_alutype_o[2] = (inst_sll|inst_sra|inst_srav|inst_sllv|inst_srlv|inst_srl);
    assign id_alutype_o[1] = (inst_and|inst_mfhi|inst_mflo|inst_ori|inst_lui|inst_andi|inst_nor|inst_or|inst_xor|inst_xori);
    assign id_alutype_o[0] = (inst_add|inst_subu|inst_slt|inst_mfhi|inst_mflo|
                               inst_addiu|inst_sltiu|inst_lb|inst_lw|inst_sb|inst_sw|inst_addu|
                               inst_addi|inst_sub|inst_lbu|inst_lh|inst_lhu|inst_sh|inst_slti|inst_sltu);

    // OP-code
    assign id_aluop_o[7] = (inst_lb|inst_lw|inst_sb|inst_sw|inst_lbu|inst_lh|inst_lhu|inst_sh);
    assign id_aluop_o[6] = 1'b0;
    assign id_aluop_o[5] = (inst_slt|inst_sltiu|inst_slti|inst_sltu|inst_nor|inst_or|inst_xor|inst_xori);
    assign id_aluop_o[4] = (inst_add|inst_subu|inst_and|inst_mult|inst_sll|
                             inst_ori|inst_addiu|inst_lb|inst_lw|inst_sb|inst_sw|inst_addu|
                             inst_addi|inst_multu|inst_sra|inst_srav|inst_sub|inst_lbu|
                             inst_lh|inst_lhu|inst_sh|inst_andi);

    assign id_aluop_o[3] =   (inst_add|inst_subu|inst_and|inst_mfhi|inst_mflo|
                               inst_ori|inst_addiu|inst_sb|inst_sw|inst_addi|inst_sub|
                               inst_mthi|inst_mtlo|inst_sh|inst_andi|inst_sllv|inst_srlv|inst_srl);

    assign id_aluop_o[2] =   (inst_slt|inst_and|inst_mult|inst_mfhi|inst_mflo|
                               inst_ori|inst_lui|inst_sltiu|inst_addu|inst_multu|inst_sub|
                               inst_mthi|inst_mtlo|inst_lhu|inst_slti|inst_sltu|inst_andi);

    assign id_aluop_o[1] =   (inst_subu|inst_slt|inst_sltiu|inst_lw|inst_sw|inst_addu|
                              inst_addi|inst_sra|inst_srav|inst_sub|inst_mthi|inst_mtlo|
                              inst_lh|inst_andi|inst_xor|inst_xori|inst_sllv|inst_srl);

    assign id_aluop_o[0] =   (inst_subu|inst_mflo|inst_sll|inst_ori|inst_lui|
                              inst_addiu|inst_sltiu|inst_addu|inst_multu|inst_sra|inst_mtlo|
                              inst_lbu|inst_lh|inst_sh|inst_slti|inst_andi|inst_or|inst_xori|inst_sllv|inst_srlv);
     // enabling signal for GPRs
    assign id_wreg_o     =    (inst_add|inst_subu|inst_slt|inst_and|inst_mfhi|
                               inst_mflo|inst_sll|inst_ori|inst_lui|inst_addiu|inst_sltiu|
                               inst_lb|inst_lw|inst_addu|inst_addi|inst_sra|inst_srav|inst_sub|
                               inst_lhu|inst_lh|inst_lbu|inst_slti|inst_sltu|inst_andi|inst_nor|inst_or|inst_xor|inst_xori|inst_sllv|inst_srlv|inst_srl);


    //enabling signal for writing hilo register
    assign id_whilo_o[1] = (inst_mult|inst_multu|inst_mthi);
    assign id_whilo_o[0] = (inst_mult|inst_multu|inst_mtlo);

    // shift signal
    wire shift = inst_sll|inst_sra|inst_srl;

    //immediate number signal

    wire immsel = inst_ori|inst_lui|inst_addiu|inst_sltiu|inst_lb|inst_lw|inst_sb|inst_sw|
                 inst_addi|inst_lhu|inst_lh|inst_lbu|inst_sh|inst_slti|inst_andi|inst_xori;

    //destination register selection signal
    wire rtsel = inst_ori|inst_lui|inst_addiu|inst_sltiu|inst_lb|inst_lw|inst_addi|
                 inst_lhu|inst_lh|inst_lbu|inst_slti|inst_andi|inst_xori;

    //Signed extension signal
    wire sext = inst_addiu|inst_sltiu|inst_lb|inst_lw|inst_sb|inst_sw|inst_addi|
                inst_lhu|inst_lh|inst_lbu|inst_sh|inst_slti;

    //signal for high semi-word signal
    wire upper = inst_lui;

    //memory to register signal
    assign id_mreg_o = (inst_lb|inst_lw|inst_lhu|inst_lh|inst_lbu);

    //rs -> ra1 , rt -> ra2
    assign ra1 = rs;
    assign ra2 = rt;
    /*------------------------------------------------------------------------------*/
    //imm number for execute
    wire [31:0] imm_ext =  (upper == `UPPER_ENABLE)? (imm << 16):
                           (sext  == `SIGNED_EXT) ? {{16{imm[15]}},imm}:
                           {{16{1'b0}},imm};

    // address of destination register to write
    assign id_wa_o = (rtsel == `RT_ENABLE)? rt:rd;

    //data to be written into the memory
    assign id_din_o = rd2;
    //generate signal to choose sorce operand
    wire [1:0] fwrd1=(exe2id_wreg==`WRITE_ENABLE && exe2id_wa==ra1)? 2'b01:
                      (mem2id_wreg==`WRITE_ENABLE && mem2id_wa==ra1)? 2'b10:2'b11;
                      
    wire [1:0] fwrd2=(exe2id_wreg==`WRITE_ENABLE && exe2id_wa==ra2)? 2'b01:
                      (mem2id_wreg==`WRITE_ENABLE && mem2id_wa==ra2)? 2'b10:2'b11; 
         
     
                     

    // shift count if shift signal is active, else data from register port 1

    assign id_src1_o = 
                       (shift==`SHIFT_ENABLE)?{27'b0,sa}:
                       (fwrd1==2'b01)? exe2id_wd:
                       (fwrd1==2'b10)? mem2id_wd:   
                       (fwrd1==2'b11)? rd1:`ZERO_WORD;
                       
                       
    // imm if imm signal is active, else the data from register port 2
    assign id_src2_o = 
                       (immsel==`IMM_ENABLE)?imm_ext:    
                       (fwrd2==2'b01)? exe2id_wd:
                       (fwrd2==2'b10)? mem2id_wd:   
                       (fwrd2==2'b11)? rd2:`ZERO_WORD;            

endmodule
