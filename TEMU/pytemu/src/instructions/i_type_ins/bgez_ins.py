from instructions.i_type_ins.IIns import I_Ins
from RegList import RegList
from ctypes import *


class bgez_ins(I_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        temp = self._imm << 2
        if temp & 0x8000:
            target_offset = c_int32(0xFFFF0000 | temp).value
        else:
            target_offset = c_int32(temp).value

        if c_int32(cpu[self._rs].low32).value >= 0:
            cpu[RegList.PC.value].low32 += target_offset

    def __str__(self):
        return f"bgez ${RegList(self._rs).name}, {hex(self._imm)}"