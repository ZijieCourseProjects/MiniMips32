from instructions.j_type_ins.JIns import J_Ins
from RegList import RegList
from ctypes import *


class jr_ins(J_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        temp = c_int32(cpu[self._rs].low32).value
        cpu[RegList.PC.value].low32 = temp

    def __str__(self):
        return f"jr ${RegList(self._rs).name}"