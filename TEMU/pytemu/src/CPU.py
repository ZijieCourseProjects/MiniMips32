from enum import Enum

import Debugger
import RegList
from Memory import Memory
from RegList import RegList
from Register import Register
from instructions.Decoder import Decoder
from util import in_print


class CPU:
    ENTRY_START = 0xbfc00000
    CPUState = Enum('CPUState', ('RUNNING', 'STOPPED'))

    def __init__(self):
        self.__memory = Memory()
        self.__registers = [Register(self, i) for i in range(35)]
        self.__golden_trace = []
        self.__registers[RegList.PC.value].low32 = self.ENTRY_START
        self.__state = self.CPUState.RUNNING
        self.__watchpoints = {}
        self.__watchpoint_id = 0

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

    def add_golden_trace(self, id, value):
        if id != RegList.PC.value:
            self.__golden_trace.append((self[RegList.PC.value].low32, id, value))

    def execute(self, instruction):
        instruction.execute(self)

    def fetch_instruction(self):
        return self.__memory.read(self[RegList.PC.value].low32, 4)

    def load_file(self, instr_file, data_file):
        self.__memory.load_file(instr_file, self.ENTRY_START)
        self.__memory.load_file(data_file, 0)

    def pre_fetch(self, num):

        a = ''
        for i in range(-num, num):
            try:
                ins = str(Decoder.decode_instr(self.__memory.read(self[RegList.PC.value].low32 + i * 4, 4)))
                a += '    ' + f"{hex(self[RegList.PC.value].low32 + i * 4)} " + f'{ins: ^30}' + '\n' if i != 0 else f'->  {hex(self[RegList.PC.value].low32 + i * 4)} ' + f'{ins: ^30}' + '\n'
            except Exception:
                a += '    ' + f"{hex(self[RegList.PC.value].low32 + i * 4)} " + 'Invalid Instruction' + '\n' if i != 0 else f'->  {hex(self[RegList.PC.value].low32 + i * 4)} ' + 'Invalid Instruction' + '\n'
        return a

    def step(self):
        instruction_byte = self.fetch_instruction()
        instruction = Decoder.decode_instr(instruction_byte)
        self.execute(instruction)
        self[RegList.PC.value].low32 += 4
        self.check_watchpoints()
        return f'{self[32].low32:08x}' + "  " + str(instruction)

    def run(self):
        self.__state = self.CPUState.RUNNING
        while self.__state == self.CPUState.RUNNING:
            in_print(self.step())

    @property
    def mem(self):
        return self.__memory

    # print registers in two column
    def print_registers(self):
        for i in range(0, 34, 2):
            in_print(f"${RegList(i).name} = {self[i].low32:08x} ${RegList(i + 1).name} = {self[i + 1].low32:08x}")
        in_print(f"${RegList(35).name} = {self[35].low32:08x}")

    def print_registers_to_str(self):
        a = ''
        for i in range(0, 34, 2):
            a += (f"${RegList(i).name: ^4} = {self[i].low32:08x} ${RegList(i + 1).name: ^4} = {self[i + 1].low32:08x}")
            if i % 4:
                a += '\n'
            else:
                a += ' '
        a += (f"${RegList(34).name: ^4} = {self[34].low32:08x}")
        return a

    def set_watchpoint(self, expr):
        self.__watchpoints[self.__watchpoint_id] = (expr, Debugger.compute(self, expr))
        self.__watchpoint_id += 1
        return self.__watchpoint_id - 1

    def check_watchpoints(self):
        for watch_id, (expr, value) in self.__watchpoints.items():
            if Debugger.compute(self, expr) != value:
                self.__state = self.CPUState.STOPPED
                in_print(f"Watchpoint {watch_id} triggered for {expr}")
                return watch_id

    def print_watchpoints(self):
        for id, (expr, value) in self.__watchpoints.items():
            in_print(f"Watchpoint {id} set for {expr}")

    def remove_watchpoint(self, id):
        self.__watchpoints.pop(id)

    def get_golden_trace(self):
        return self.__golden_trace
