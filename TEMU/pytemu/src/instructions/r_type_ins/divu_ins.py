import instructions.r_type_ins.RIns as RIns
from RegList import RegList
from ctypes import *

class divu_ins(RIns.R_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        lo = cpu[self._rs].low32 / cpu[self._rt].low32 
        hi = cpu[self._rs].low32 % cpu[self._rt].low32
        cpu[34].low32 = c_uint32(lo).value
        cpu[33].low32 = c_uint32(hi).value

    def __str__(self):
        return f"divu ${RegList(self._rs).name}, ${RegList(self._rt).name}"