import instructions.r_type_ins.RIns as RIns
from src.RegList import RegList
from ctypes import *

class div_ins(RIns.R_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        lo = c_int32(cpu[self._rs].low32).value / c_int32(cpu[self._rt].low32).value 
        hi = c_int32(cpu[self._rs].low32).value % c_int32(cpu[self._rt].low32).value
        cpu[34].low32 = c_int32(lo).value
        cpu[33].low32 = c_int32(hi).value

    def __str__(self):
        return f"div ${RegList(self._rs).name}, ${RegList(self._rt).name}"