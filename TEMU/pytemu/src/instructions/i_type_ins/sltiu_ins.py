from instructions.i_type_ins.IIns import I_Ins
from RegList import RegList
from ctypes import *


class sltiu_ins(I_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        if self._imm & 0x8000:
            temp = c_int32(0xFFFF0000 | self._imm).value
        else:
            temp = c_int32(self._imm).value
        if c_uint32(temp).value > cpu[self._rs].low32:
            cpu[self._rt].low32 = 1
        else:
            cpu[self._rt].low32 = 0

    def __str__(self):
        return f"sltiu ${RegList(self._rt).name}, ${RegList(self._rs).name}, {hex(self._imm)}"