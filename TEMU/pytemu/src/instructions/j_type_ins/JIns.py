from instructions.Instruction import Instruction


class J_Ins(Instruction):
    def __init__(self, instr):
        self._instruction = instr
        self._imm = instr & 0x3ffffff
