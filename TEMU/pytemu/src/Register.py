# This is a sample Python script.

# Press ⌃R to execute it or replace it with your code.
# Press Double ⇧ to search everywhere for classes, files, tool windows, actions, and settings.

import numpy as np


class Register:
    def __init__(self, cpu, reg_id):
        self.__value = np.uint32(0)
        self.__cpu = cpu
        self.__id = reg_id

    def reset(self):
        self.__value = np.uint32(0)

    @property
    def low32(self) -> np.uint32:
        return self.__value

    @low32.setter
    def low32(self, value):
        self.__value = np.uint32(value)
        self.__cpu.add_golden_trace(self.__id, value)

    @property
    def low16(self) -> np.uint16:
        return np.uint16(self.__value)

    @low16.setter
    def low16(self, value):
        self.__value = (self.__value & 0xFFFF0000) | np.uint16(value)
        self.__cpu.add_golden_trace(self.__id, value)

    @property
    def low8(self) -> np.uint8:
        return np.uint8(self.__value)

    @low8.setter
    def low8(self, value):
        self.__value = (self.__value & 0xFFFFFF00) | np.uint8(value)
        self.__cpu.add_golden_trace(self.__id, value)

    def __str__(self):
        return str(self.__value)


class StatusRegister(Register):

    @property
    def ie(self) -> bool:
        return bool(self.low32 & 1)

    @ie.setter
    def ie(self, value):
        if value:
            self.low32 |= 1
        else:
            self.low32 &= ~1

    @property
    def exl(self) -> bool:
        return bool(self.low32 & 2)

    @exl.setter
    def exl(self, value):
        if value:
            self.low32 |= 2
        else:
            self.low32 &= 0xFFFFFFFD

    def im(self, no):
        return bool(self.low32 & (1 << (8 + no)))

    def set_im(self, no, value):
        if value:
            self.low32 |= (1 << (8 + no))
        else:
            self.low32 &= ~(1 << (8 + no))


class Cause(Register):
    @property
    def exc_code(self) -> np.uint8:
        return np.uint8(self.low32 & 0x7C)

    @exc_code.setter
    def exc_code(self, value):
        self.low32 = (self.low32 & 0xFFFFFF83) | (np.uint8(value) << 2)

    @property
    def bd(self) -> bool:
        return bool(self.low32 & 0x80000000)

    @bd.setter
    def bd(self, value):
        if value:
            self.low32 |= 0x80000000
        else:
            self.low32 &= 0x7FFFFFFF

    def ip(self, no):
        return bool(self.low32 & (1 << (8 + no)))

    def set_ip(self, no, value):
        if value:
            self.low32 |= (1 << (8 + no))
        else:
            self.low32 &= ~(1 << (8 + no))
