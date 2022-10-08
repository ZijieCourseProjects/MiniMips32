import instructions.r_type_ins.RIns as RIns
from RegList import RegList
from ctypes import *

class subu_ins(RIns.R_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        res = (cpu[self._rs].low32 - cpu[self._rt].low32) & 0xFFFFFFFF
        cpu[self._rd].low32 = c_uint32(res).value
        
    def __str__(self):
        return f"subu ${RegList(self._rd).name}, ${RegList(self._rs).name}, ${RegList(self._rt).name}"