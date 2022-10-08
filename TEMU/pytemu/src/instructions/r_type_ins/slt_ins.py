import instructions.r_type_ins.RIns as RIns
from RegList import RegList
from ctypes import *

class slt_ins(RIns.R_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        if c_int32(cpu[self._rs].low32).value < c_int32(cpu[self._rt].low32).value:
            cpu[self._rd].low32 = 1
        else:
            cpu[self._rd].low32 = 0

    def __str__(self):
        return f"slt ${RegList(self._rd).name}, ${RegList(self._rs).name}, ${RegList(self._rt).name}"