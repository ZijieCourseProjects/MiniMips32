from RegList import RegList
from instructions.j_type_ins.JIns import J_Ins


class j_ins(J_Ins):
    def __init__(self, instruction):
        super().__init__(instruction)
        self._addr = None

    def execute(self, cpu):
        temp1 = cpu[RegList.PC.value].low32 & 0xF0000000
        temp2 = self._imm << 2
        cpu[RegList.PC.value].low32 = temp1 | temp2
        self._addr = cpu[RegList.PC.value].low32

    def __str__(self):
        return f"j {self._addr}"
