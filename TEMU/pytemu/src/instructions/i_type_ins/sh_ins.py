from instructions.i_type_ins.IIns import I_Ins
from RegList import RegList
from instructions.Instruction import signed_extend



class sh_ins(I_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, cpu):
        addr = cpu[self._rs].low32 + signed_extend(self._imm, 16)
        cpu.mem.write(addr, cpu[self._rt].low16, 2)

    def __str__(self):
        return f"sh ${RegList(self._rt).name}, {self._imm}(${RegList(self._rs).name})"