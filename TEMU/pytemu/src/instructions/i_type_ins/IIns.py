from instructions.Instruction import Instruction


class I_Ins(Instruction):
    def __init__(self, instruction):
        self._instruction = instruction
        self._rs = (instruction >> 21) & 0x1f
        self._rt = (instruction >> 16) & 0x1f
        self._imm = instruction & 0xffff
