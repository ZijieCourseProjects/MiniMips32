from src.instructions.Instruction import Instruction


class R_Ins(Instruction):
    @staticmethod
    def r_ins_factory(instruction):
        pass

    def __init__(self, instruction):
        self.__instruction = instruction
        self.__rs = (instruction >> 21) & 0x1f
        self.__rt = (instruction >> 16) & 0x1f
        self.__rd = (instruction >> 11) & 0x1f
        self.__shamt = (instruction >> 6) & 0x1f
        self.__funct = instruction & 0x3f

    @property
    def rs(self):
        return self.__rs

    @property
    def rt(self):
        return self.__rt