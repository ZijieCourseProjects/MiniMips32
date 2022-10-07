from instructions.r_type_ins import *
from instructions.j_type_ins import *
from instructions.i_type_ins import *


class Decoder:
    R_TYPE_FUNC = {
        0x24: and_ins.and_ins,
        0x20: add_ins.add_ins,
        0x21: addu_ins.addu_ins,
        0x22: sub_ins.sub_ins,
        0x23: subu_ins.subu_ins,
        0x2A: slt_ins.slt_ins,
        0x2A: sltu_ins.sltu_ins,
        0x1A: div_ins.div_ins,
        0x1B: divu_ins,divu_ins,
        0x18: mult_ins,mult_ins,
        0x19: multu_ins,multu_ins,
        0x27: nor_ins,nor_ins,
        0x25: or_ins,or_ins,
        0x26: xor_ins,xor_ins
    }

    IJ_TYPE_OP = {
        0x0F: lui_ins.lui_ins,
        0x0D: ori_ins.ori_ins,
        0x12: trap_ins.trap_ins,
        0x08: addi_ins.addi_ins,
        0x09: addiu_ins.addiu_ins,
        0X0A: slti_ins.slti_ins,
        0x0B: sltiu_ins.sltiu_ins,
        0x0C: andi_ins,andi_ins,
        0x0E: xori_ins,xori_ins

    }

    @staticmethod
    def decode_r_type(instr):
        return Decoder.R_TYPE_FUNC[instr & 0x3f](instr)

    @staticmethod
    def decode_instr(instr):
        try:
            if instr >> 26 == 0:
                return Decoder.decode_r_type(instr)
            else:
                return Decoder.IJ_TYPE_OP[instr >> 26](instr)
        except KeyError:
            raise Exception(f"Unknown instruction: {hex(instr)}")

