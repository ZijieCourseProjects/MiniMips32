from instructions.i_type_ins.IIns import I_Ins
from RegList import RegList


class addi_ins(I_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        # TODO integer overflow
        if self._imm & 0x8000:
            temp = 0xFFFF0000 | self._imm
        else:
            temp = self._imm
        cpu[self._rt].low32 = temp + cpu[self._rs].low32

    def __str__(self):
        return f"addi ${RegList(self._rt).name}, ${RegList(self._rs).name}, {hex(self._imm)}"