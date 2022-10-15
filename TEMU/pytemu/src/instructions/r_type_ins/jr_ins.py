from ctypes import *

import instructions.r_type_ins.RIns as RIns
from RegList import RegList


class jr_ins(RIns.R_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        temp = c_int32(cpu[self._rs].low32).value
        cpu[RegList.PC.value].low32 = temp

    def __str__(self):
        return f"jr ${RegList(self._rs).name}"
