from ctypes import *

from RegList import RegList
from instructions.Instruction import signed_extend
from instructions.i_type_ins.IIns import I_Ins


class bgezal_ins(I_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        temp = self._imm << 2
        target_offset = signed_extend(temp, 18)

        cpu[31].low32 = c_int32(cpu[RegList.PC.value].low32).value + 8

        if c_int32(cpu[self._rs].low32).value >= 0:
            cpu[RegList.PC.value].low32 += target_offset

    def __str__(self):
        return f"bgezal ${RegList(self._rs).name}, {hex(self._imm)}"
