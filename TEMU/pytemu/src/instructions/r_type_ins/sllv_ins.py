from ctypes import *

import instructions.r_type_ins.RIns as RIns
from RegList import RegList


class sllv_ins(RIns.R_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        s = c_int32(cpu[self._rs].low32).value
        res = c_int32(cpu[self._rt].low32).value << s
        cpu[self._rd].low32 = res

    def __str__(self):
        return f"sllv ${RegList(self._rd).name}, ${RegList(self._rt).name}, ${RegList(self._rs).name}"
