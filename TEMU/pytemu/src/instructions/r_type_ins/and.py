import RIns


class and_ins(RIns):
    def __init__(self, instruction):
        super().__init__(instruction)

    def execute(self, registers):
        registers[self._rd] = registers[self._rs] & registers[self._rt]

    def __str__(self):
        return "and ${0}, ${1}, ${2}".format(self.rd, self.rs, self.rt)
