from RegList import RegList
from instructions.Instruction import Instruction


# noinspection PyUnusedLocal
class eret_ins(Instruction):
    def __init__(self, instruction):
        pass

    def execute(self, cpu):
        cpu[RegList.PC].low32 = cpu.cp0[RegList.EPC].low32 - 4
        cpu.cp0[RegList.STATUS].exl = False

    def __str__(self):
        return f"eret"
