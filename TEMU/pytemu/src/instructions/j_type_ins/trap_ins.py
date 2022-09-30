from instructions.i_type_ins.IIns import I_Ins
from util import in_print


class trap_ins(I_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        in_print("hit good trap XD")
        cpu.stop()

    def __str__(self):
        return "trap"
