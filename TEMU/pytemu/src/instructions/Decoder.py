from instructions.r_type_ins import *
from instructions.j_type_ins import *
from instructions.i_type_ins import *


class Decoder:
    R_TYPE_FUNC = {
        0x24: and_ins.and_ins
    }

    IJ_TYPE_OP = {
        0x0F: lui_ins.lui_ins,
        0x0D: ori_ins.ori_ins,
        0x12: trap_ins.trap_ins
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

