import instructions.r_type_ins.RIns as RIns
from RegList import RegList
from ctypes import *


class mfhi_ins(RIns.R_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        # HI = 33
        cpu[self._rd].low32 = c_int32(cpu[33].low32).value

    def __str__(self):
        return f"mfhi ${RegList(self._rd).name}"