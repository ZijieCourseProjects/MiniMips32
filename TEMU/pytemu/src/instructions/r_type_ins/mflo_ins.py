from ctypes import *

import instructions.r_type_ins.RIns as RIns
from RegList import RegList


class mflo_ins(RIns.R_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        # LO = 34
        cpu[self._rd].low32 = c_int32(cpu[34].low32).value

    def __str__(self):
        return f"mflo ${RegList(self._rd).name}"
