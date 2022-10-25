from RegList import RegList
from instructions.Instruction import Instruction


class mtc0_ins(Instruction):
    def __init__(self, instruction):
        self.__rd = (instruction >> 11) & 0x1F
        self.__rt = (instruction >> 16) & 0x1F

    def execute(self, cpu):
        cpu.cp0[self.__rd + 40].low32 = cpu[self.__rt].low32

    def __str__(self):
        return f"mtc0 {RegList(self.__rt).name}, {RegList(self.__rd + 40).name}"
