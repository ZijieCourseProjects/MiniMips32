from src.instructions.Instruction import Instruction


class R_Ins(Instruction):

    def __init__(self, instruction):
        self._instruction = instruction
        self._rs = (instruction >> 21) & 0x1f
        self._rt = (instruction >> 16) & 0x1f
        self._rd = (instruction >> 11) & 0x1f
        self._shamt = (instruction >> 6) & 0x1f
        self._funct = instruction & 0x3f
