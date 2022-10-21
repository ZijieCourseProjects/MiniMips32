from instructions.i_type_ins.IIns import I_Ins
from RegList import RegList
from instructions.Instruction import signed_extend
from ExcCode import ExcCode


class sw_ins(I_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        addr = cpu[self._rs].low32 + signed_extend(self._imm, 16)
        if addr % 4 == 0:
            cpu.mem.write(addr, cpu[self._rt].low32, 4)
        else:
            cpu.raise_exption(ExcCode.ADES)

    def __str__(self):
        return f"sw {RegList(self._rt).name}, {self._imm}({RegList(self._rs).name})"

