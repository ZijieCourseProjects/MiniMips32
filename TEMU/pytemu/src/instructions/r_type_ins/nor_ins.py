import instructions.r_type_ins.RIns as RIns
from RegList import RegList


class nor_ins(RIns.R_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        cpu[self._rd].low32 = ~(cpu[self._rs].low32 | cpu[self._rt].low32)

    def __str__(self):
        return f"nor ${RegList(self._rd).name}, ${RegList(self._rs).name}, ${RegList(self._rt).name}"