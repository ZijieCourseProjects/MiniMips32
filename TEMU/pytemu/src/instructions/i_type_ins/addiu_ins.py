from ctypes import *

from RegList import RegList
from instructions.Instruction import signed_extend
from instructions.i_type_ins.IIns import I_Ins


class addiu_ins(I_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        temp = signed_extend(self._imm, 16)
        res = temp + cpu[self._rs].low32
        cpu[self._rt].low32 = c_uint32(res).value

    def __str__(self):
        return f"addiu ${RegList(self._rt).name}, ${RegList(self._rs).name}, {hex(self._imm)}"
