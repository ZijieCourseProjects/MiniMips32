from Register import Register
from RegList import *
from Memory import Memory


class CPU:
    ENTRY_START = 0xbfc00000

    def __init__(self):
        self.__memory = Memory()
        self.__registers = [Register() for i in range(35)]

    def __getitem__(self, item: RegList) -> Register:
        if item not in RegList:
            raise ValueError(f"Invalid register {item}")
        return self.__registers[item.value]

    def __setitem__(self, key: RegList, value: Register):
        if key not in RegList:
            raise ValueError(f"Invalid register {key}")
        self.__registers[key.value] = value

    def execute(self, instruction):
        pass

    def fetch_instruction(self):
        pass

    def load_file(self):
        self.__memory.load_file('/Users/higgs/MiniMIPS32/TEMU/inst.bin', self.ENTRY_START & 0x1fffffff)
        self.__memory.load_file('/Users/higgs/MiniMIPS32/TEMU/data.bin', 0)
        print(self.__memory.read(self.ENTRY_START & 0x1fffffff, 4))


if __name__ == '__main__':
    cpu = CPU()
    cpu.load_file()
    pass
