import instructions.r_type_ins.RIns as RIns
from RegList import RegList
from ExcCode import ExcCode


class break_ins(RIns.R_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        cpu.raise_exption(ExcCode.BP)

    def __str__(self):
        return f"break"
