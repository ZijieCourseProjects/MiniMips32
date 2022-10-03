from instructions.i_type_ins.IIns import I_Ins
from RegList import RegList


class ori_ins(I_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        cpu[self._rt].low32 = cpu[self._rs].low32 | self._imm

    def __str__(self):
        return f"ori ${RegList(self._rt).name}, ${RegList(self._rs).name}, {hex(self._imm)}"
