from instructions.j_type_ins.JIns import J_Ins
from RegList import RegList
from ctypes import *


class j_ins(J_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        temp1 = cpu[RegList.PC.value].low32 & 0xF0000000
        temp2 = self._imm << 2
        cpu[RegList.PC.value].low32 = temp1 | temp2

    def __str__(self, cpu):
        return f"j {cpu[RegList.PC.value].low32}"