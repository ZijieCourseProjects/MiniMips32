import instructions.r_type_ins.RIns as RIns
from RegList import RegList
from ctypes import *


class mtlo_ins(RIns.R_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        # LO = 34
        cpu[34].low32 = c_int32(cpu[self._rs].low32).value

    def __str__(self):
        return f"mtlo ${RegList(self._rs).name}"