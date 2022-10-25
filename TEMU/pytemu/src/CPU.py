from enum import Enum

import Debugger
import ExcCode
import RegList
from Memory import Memory
from RegList import RegList
from Register import Register, StatusRegister, Cause
from instructions.Decoder import Decoder
from util import in_print


class CPU:
    ENTRY_START = 0xbfc00000
    CPUState = Enum('CPUState', ('RUNNING', 'STOPPED'))

    def __init__(self):
        self.__memory = Memory()
        self.__registers = [Register(self, i) for i in range(35)]
        self.__cp0 = {RegList.STATUS: StatusRegister(self, RegList.STATUS.value),
                      RegList.EPC: Register(self, RegList.EPC.value), RegList.CAUSE: Cause(self, RegList.CAUSE.value)}
        self.__golden_trace = []
        self.__registers[RegList.PC.value].low32 = self.ENTRY_START
        self.__state = self.CPUState.RUNNING
        self.__watchpoints = {}
        self.__instrs = {}
        self.__watchpoint_id = 0

    @property
    def instrs(self):
        return self.__instrs

    def fetch_all_instruction(self):
        for i in range(self.__instr_count):
            self.__instrs[self.ENTRY_START + 4 * i] = Decoder.decode_instr(
                self.__memory.read(self.ENTRY_START + i * 4, 4))

    def reset(self):
        for reg in self.__registers:
            reg.reset()
        for index, reg in self.__cp0.items():
            reg.reset()

        self[RegList.PC.value].low32 = self.ENTRY_START

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
        self.__instr_count = int(self.__memory.load_file(instr_file, self.ENTRY_START) / 4)
        self.__memory.load_file(data_file, 0)

    def pre_fetch(self, num):

        a = ''
        for i in range(-num, num):
            try:
                ins = str(Decoder.decode_instr(self.__memory.read(self[RegList.PC.value].low32 + i * 4, 4)))
                a += '    ' + f"{hex(self[RegList.PC.value].low32 + i * 4)} " + f'{ins: ^30}' + '\n' if i != 0 else f'->  {hex(self[RegList.PC.value].low32 + i * 4)} ' + f'{ins: ^30}' + '\n '
            except Exception:
                a += '    ' + f"{hex(self[RegList.PC.value].low32 + i * 4)} " + 'Invalid Instruction' + '\n' if i != 0 else f'->  {hex(self[RegList.PC.value].low32 + i * 4)} ' + 'Invalid Instruction' + '\n'
        return a

    def step(self):
        self.__state = self.CPUState.RUNNING
        current_pc = self[RegList.PC.value].low32
        if current_pc & 0x3 != 0:
            self.raise_exption(ExcCode.ExcCode.ADEL)
            return f'PC is not aligned to 4 bytes: {hex(current_pc)}'

        instruction_byte = self.fetch_instruction()

        instruction = Decoder.decode_instr(instruction_byte)

        if instruction == None:
            self.raise_exption(ExcCode.ExcCode.RI)
            return f'Invalid instruction: {hex(instruction_byte)}'

        self.execute(instruction)

        if not self.check_intterupt() and not self.__state == self.CPUState.STOPPED:
            self[RegList.PC.value].low32 += 4

        self.check_watchpoints()
        return f'{current_pc:08x}' + "  " + str(instruction)

    def run(self):
        self.__state = self.CPUState.RUNNING
        while self.__state == self.CPUState.RUNNING:
            in_print(self.step())

    @property
    def mem(self):
        return self.__memory

    @property
    def cp0(self):
        return self.__cp0

    def raise_exption(self, exec_code):
        if not self.cp0[RegList.STATUS].exl:
            self.cp0[RegList.EPC].low32 = self[RegList.PC.value].low32
            self.cp0[RegList.STATUS].exl = True
            self.cp0[RegList.CAUSE].bd = False
            self.cp0[RegList.CAUSE].exc_code = exec_code
            self[RegList.PC.value].low32 = 0xBFC00380 - 4

    def check_intterupt(self):
        if self.cp0[RegList.STATUS].exl or not self.cp0[RegList.STATUS].ie:
            return
        for no in range(8):
            if not self.cp0[RegList.STATUS].im(no):
                continue
            if self.cp0[RegList.STATUS].ip(no):
                self.cp0[RegList.EPC] = self[RegList.PC.value].low32
                self[RegList.PC.value].low32 = 0xBFC00380
                return True
        return False

    # print registers in two column
    def print_registers(self):
        for i in range(0, 34, 2):
            in_print(f"${RegList(i).name} = {self[i].low32:08x} ${RegList(i + 1).name} = {self[i + 1].low32:08x}")
        in_print(f"${RegList(35).name} = {self[35].low32:08x}")

    def registers(self):
        return self.__registers, self.__cp0

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
        return id

    def get_golden_trace(self):
        return self.__golden_trace
