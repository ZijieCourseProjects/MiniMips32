from ctypes import *

import instructions.r_type_ins.RIns as RIns
from RegList import RegList


class sll_ins(RIns.R_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        s = c_int32(self._sa).value
        res = c_int32(cpu[self._rt].low32).value << s
        cpu[self._rd].low32 = res

    def __str__(self):
        return f"sll ${RegList(self._rd).name}, ${RegList(self._rt).name}, {hex(self._sa)}"
