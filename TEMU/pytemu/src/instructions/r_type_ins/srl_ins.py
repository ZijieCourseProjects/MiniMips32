import instructions.r_type_ins.RIns as RIns
from RegList import RegList
from ctypes import *


class srl_ins(RIns.R_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        s = c_int32(self._sa).value
        res = c_uint32(cpu[self._rt].low32).value >> s
        cpu[self._rd].low32 = res

    def __str__(self):
        return f"srl ${RegList(self._rd).name}, ${RegList(self._rt).name}, {hex(self._sa)}"
