from RegList import RegList
from instructions.i_type_ins.IIns import I_Ins


class xori_ins(I_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        cpu[self._rt].low32 = cpu[self._rs].low32 ^ (self._imm | 0x00000000)

    def __str__(self):
        return f"xori ${RegList(self._rt).name}, ${RegList(self._rs).name}, {hex(self._imm)}"
