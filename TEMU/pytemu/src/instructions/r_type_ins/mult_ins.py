import instructions.r_type_ins.RIns as RIns
from src.RegList import RegList
from ctypes import *

class mult_ins(RIns.R_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        if c_int32(cpu[self._rs].low32).value < 0:
            val1 = c_int64((0xFFFFFFFF << 32) | cpu[self._rs].low32).value
        else:
            val1 = c_int64(cpu[self._rs].low32).value

        if c_int32(cpu[self._rt].low32).value < 0:
            val2 = c_int64((0xFFFFFFFF << 32) | cpu[self._rt].low32).value
        else:
            val2 = c_int64(cpu[self._rt].low32).value

        res = c_uint64(val1 * val2).value
        cpu[34].low32 = c_uint32(res & 0xFFFFFFFF).value 
        cpu[33].low32 = c_uint32((res >> 32) & 0xFFFFFFFF).value

    def __str__(self):
        return f"mult ${RegList(self._rs).name}, ${RegList(self._rt).name}"