from ctypes import *

import instructions.r_type_ins.RIns as RIns
from RegList import RegList
from ExcCode import ExcCode


class sub_ins(RIns.R_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        res = (c_int32(cpu[self._rs].low32).value - c_int32(cpu[self._rt].low32).value) & 0xFFFFFFFF
        if (cpu[self._rs].low32 & 0x80000000) != (cpu[self._rt].low32 & 0x80000000) and (res & 0x80000000) != (
                cpu[self._rs].low32 & 0x80000000):
            cpu.raise_exption(ExcCode.OV)
        cpu[self._rd].low32 = c_int32(res).value

    def __str__(self):
        return f"sub ${RegList(self._rd).name}, ${RegList(self._rs).name}, ${RegList(self._rt).name}"
