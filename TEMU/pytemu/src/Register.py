# This is a sample Python script.

# Press ⌃R to execute it or replace it with your code.
# Press Double ⇧ to search everywhere for classes, files, tool windows, actions, and settings.

import numpy as np


class Register:
    def __init__(self, cpu, id):
        self.__value = np.uint32(0)
        self.__cpu = cpu
        self.__id = id

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

    @property
    def low8(self) -> np.uint8:
        return np.uint8(self.__value)

    @low8.setter
    def low8(self, value):
        self.__value = (self.__value & 0xFFFFFF00) | np.uint8(value)

    def __str__(self):
        return str(self.__value)
