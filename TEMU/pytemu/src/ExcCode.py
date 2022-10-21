from enum import Enum


class ExcCode(int, Enum):
    INT = 0
    MOD = 1
    TLBL = 2
    TLBS = 3
    ADEL = 4
    ADES = 5
    IBE = 6
    DBE = 7
    SYS = 8
    BP = 9
    RI = 10
    CPU = 11
    OV = 12
    TR = 13
    FPE = 15
    WATCH = 23
    MCHK = 24
    CACHE = 30
