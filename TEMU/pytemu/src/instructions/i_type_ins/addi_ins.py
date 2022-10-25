from ctypes import *

from RegList import RegList
from instructions.Instruction import signed_extend
from instructions.i_type_ins.IIns import I_Ins
from ExcCode import ExcCode


class addi_ins(I_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        temp = signed_extend(self._imm, 16)
        res = temp + c_int32(cpu[self._rs].low32).value
        if (cpu[self._rs].low32 & 0x80000000) == (temp & 0x80000000) and (res & 0x80000000) != (
                cpu[self._rs].low32 & 0x80000000):
            cpu.raise_exption(ExcCode.OV)
        cpu[self._rt].low32 = c_int32(res).value

    def __str__(self):
        return f"addi ${RegList(self._rt).name}, ${RegList(self._rs).name}, {hex(self._imm)}"
