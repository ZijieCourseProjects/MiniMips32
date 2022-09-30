from src.instructions.Instruction import Instruction


class R_Ins(Instruction):
    @staticmethod
    def r_ins_factory(instruction):
        pass

    def __init__(self, instruction):
        self._instruction = instruction
        self._rs = (instruction >> 21) & 0x1f
        self._rt = (instruction >> 16) & 0x1f
        self._rd = (instruction >> 11) & 0x1f
        self._shamt = (instruction >> 6) & 0x1f
        self._funct = instruction & 0x3f

    @property
    def rs(self):
        return self._rs

    @property
    def rt(self):
        return self._rt

    @property
    def rd(self):
        return self._rd

    @property
    def shamt(self):
        return self._shamt

    @property
    def funct(self):
        return self._funct
