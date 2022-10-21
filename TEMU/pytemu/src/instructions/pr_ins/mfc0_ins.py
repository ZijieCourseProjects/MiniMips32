from instructions.Instruction import Instruction
from RegList import RegList


class mfc0_ins(Instruction):
    def __init__(self, instruction):
        self.__rd = (instruction >> 11) & 0x1F
        self.__rt = (instruction >> 16) & 0x1F

    def execute(self, cpu):
        cpu[self.__rt].low32 = cpu.cp0[self.__rd + 40].low32

    def __str__(self):
        return f"mfc0 {RegList(self.__rt).name}, {RegList(self.__rd).name}"
