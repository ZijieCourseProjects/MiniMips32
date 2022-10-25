from instructions.Instruction import Instruction


class nop_ins(Instruction):
    def __init__(self, instruction):
        pass

    def execute(self, cpu):
        pass

    def __str__(self):
        return f"nop"
