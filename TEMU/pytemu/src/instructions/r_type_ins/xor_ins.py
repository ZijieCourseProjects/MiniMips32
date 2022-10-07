import instructions.r_type_ins.RIns as RIns
from src.RegList import RegList


class xor_ins(RIns.R_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        cpu[self._rd].low32 = cpu[self._rs].low32 ^ cpu[self._rt].low32

    def __str__(self):
        return f"xor ${RegList(self._rd).name}, ${RegList(self._rs).name}, ${RegList(self._rt).name}"