from ctypes import *

from RegList import RegList
from instructions.Instruction import signed_extend
from instructions.i_type_ins.IIns import I_Ins


class slti_ins(I_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        temp = signed_extend(self._imm, 16)
        if temp > c_int32(cpu[self._rs].low32).value:
            cpu[self._rt].low32 = 1
        else:
            cpu[self._rt].low32 = 0

    def __str__(self):
        return f"slti ${RegList(self._rt).name}, ${RegList(self._rs).name}, {hex(self._imm)}"
