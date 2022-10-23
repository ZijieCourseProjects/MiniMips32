from instructions.i_type_ins.IIns import I_Ins
from RegList import RegList
from instructions.Instruction import signed_extend
from ctypes import *
from ExcCode import ExcCode

class lh_ins(I_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        addr = cpu[self._rs].low32 + signed_extend(self._imm, 16)
        if addr % 2 == 0:
            cpu[self._rt].low32 = signed_extend(cpu.mem.read(addr, 2), 16)
        else:
            cpu.raise_exption(ExcCode.ADEL)

    def __str__(self):
        return f"lh ${RegList(self._rt).name}, {self._imm}(${RegList(self._rs).name})"
