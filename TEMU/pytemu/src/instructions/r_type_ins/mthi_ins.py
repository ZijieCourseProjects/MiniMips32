from ctypes import *

import instructions.r_type_ins.RIns as RIns
from RegList import RegList


class mthi_ins(RIns.R_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        # HI = 33
        cpu[33].low32 = c_int32(cpu[self._rs].low32).value

    def __str__(self):
        return f"mthi ${RegList(self._rs).name}"
