from enum import Enum

import RegList
from util import in_print
from Register import Register
from RegList import RegList
from Memory import Memory
from instructions.Decoder import Decoder


class CPU:
    ENTRY_START = 0xbfc00000
    CPUState = Enum('CPUState', ('RUNNING', 'STOPPED'))

    def __init__(self):
        self.__memory = Memory()
        self.__registers = [Register() for _ in range(35)]
        self.__registers[RegList.PC.value].low32 = self.ENTRY_START & 0x1fffffff
        self.__state = self.CPUState.RUNNING

    def stop(self):
        in_print('CPU stopped!')
        self.__state = self.CPUState.STOPPED

    def __getitem__(self, item) -> Register:
        if RegList(item) not in RegList:
            raise ValueError(f"Invalid register {item}")
        return self.__registers[item]

    def __setitem__(self, key, value):
        if RegList(key) not in RegList:
            raise ValueError(f"Invalid register {key}")
        self.__registers[key] = value

    def execute(self, instruction):
        instruction.execute(self)

    def fetch_instruction(self):
        return self.__memory.read(self[RegList.PC.value].low32, 4)

    def load_file(self, instr_file, data_file):
        self.__memory.load_file(instr_file, self.ENTRY_START & 0x1fffffff)
        self.__memory.load_file(data_file, 0)

    def step(self):
        instruction_byte = self.fetch_instruction()
        instruction = Decoder.decode_instr(instruction_byte)
        in_print(f'{self[32].low32:08x}' + "  " + str(instruction))
        self.execute(instruction)
        self[RegList.PC.value].low32 += 4

    def run(self):
        while self.__state == self.CPUState.RUNNING:
            self.step()

    @property
    def mem(self):
        return self.__memory

    # print registers in two column
    def print_registers(self):
        for i in range(0, 32, 2):
            in_print(f"${RegList(i).name} = {self[i].low32:08x} ${RegList(i + 1).name} = {self[i + 1].low32:08x}")
        in_print(f"${RegList(32).name} = {self[32].low32:08x}")
