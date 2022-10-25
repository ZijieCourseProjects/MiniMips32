import instructions.r_type_ins.RIns as RIns
from ExcCode import ExcCode


class syscall_ins(RIns.R_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        cpu.raise_exption(ExcCode.SYS)

    def __str__(self):
        return f"syscall"
