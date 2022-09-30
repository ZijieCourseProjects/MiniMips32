from instructions.i_type_ins.IIns import I_Ins
from src.RegList import RegList


class lui_ins(I_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        cpu[self._rt].low32 = self._imm << 16

    def __str__(self):
        return f"lui ${RegList(self._rt).name}, {hex(self._imm)}"
