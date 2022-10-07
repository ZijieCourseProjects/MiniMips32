import instructions.r_type_ins.RIns as RIns
from src.RegList import RegList
from ctypes import *

class multu_ins(RIns.R_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        res = c_uint64(c_uint64(cpu[self._rs].low32).value * c_uint64(cpu[self._rt].low32).value).value
        cpu[34].low32 = c_uint32(res & 0xFFFFFFFF).value 
        cpu[33].low32 = c_uint32((res >> 32) & 0xFFFFFFFF).value

    def __str__(self):
        return f"multu ${RegList(self._rs).name}, ${RegList(self._rt).name}"