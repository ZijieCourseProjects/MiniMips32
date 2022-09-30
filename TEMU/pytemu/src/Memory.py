import numpy as np


class Memory:
    COL_WIDTH = 10
    ROW_WIDTH = 10
    BANK_WIDTH = 3
    RANK_WIDTH = 29 - COL_WIDTH - ROW_WIDTH - BANK_WIDTH

    NR_COL = (1 << COL_WIDTH)
    NR_ROW = (1 << ROW_WIDTH)
    NR_BANK = (1 << BANK_WIDTH)
    NR_RANK = (1 << RANK_WIDTH)

    HW_MEM_SIZE = 1 << (COL_WIDTH + ROW_WIDTH + BANK_WIDTH + RANK_WIDTH)

    BURST_LEN = 8
    BURST_MASK = BURST_LEN - 1

    RB = np.dtype(
        [('valid', np.bool_), ('row_index', np.uint32), ('buf', (np.uint8, NR_COL))])

    def resolve_dram_address(self, address):
        rank = address >> (self.COL_WIDTH + self.ROW_WIDTH + self.BANK_WIDTH)
        bank = (address >> (self.COL_WIDTH + self.ROW_WIDTH)) & ((1 << self.BANK_WIDTH) - 1)
        row = (address >> self.COL_WIDTH) & ((1 << self.ROW_WIDTH) - 1)
        col = address & ((1 << self.COL_WIDTH) - 1)
        return rank, bank, row, col

    def __init__(self):
        self.__memory = np.ndarray(shape=(Memory.NR_RANK, Memory.NR_RANK, Memory.NR_ROW, Memory.NR_COL), dtype=np.uint8)
        self.__rowbufs = np.ndarray(shape=(self.NR_RANK, self.NR_BANK), dtype=self.RB)
        for rb in self.__rowbufs:
            rb['valid'] = np.False_

    def ddr3_read(self, address):
        if address > self.HW_MEM_SIZE:
            raise ValueError(f"Invalid memory address {address}")
        rank, bank, row, col = self.resolve_dram_address(address & ~self.BURST_MASK)
        rowbuf = self.__rowbufs[rank, bank]
        if not rowbuf['valid'] or rowbuf['row_index'] != row:
            rowbuf['valid'] = np.True_
            rowbuf['row_index'] = row
            rowbuf['buf'] = self.__memory[rank, bank, row, :]
        return rowbuf['buf']

    def ddr3_write(self, address, data, mask):
        if address > self.HW_MEM_SIZE:
            raise ValueError(f"Invalid memory address {address}")
        rank, bank, row, col = self.resolve_dram_address(address & ~self.BURST_MASK)
        rowbuf = self.__rowbufs[rank, bank]

        if not rowbuf.valid or rowbuf.row_index != row:
            rowbuf['valid'] = np.False_
            rowbuf['row_index'] = row
            rowbuf['buf'] = self.__memory[rank, bank, row, :]

        for i in range(self.BURST_LEN):
            if mask[i]:
                rowbuf.buf[col + i] = data[i]

        self.__memory[rank, bank, row, :] = rowbuf['buf']

    def read(self, address, len):
        offset = address & self.BURST_MASK
        data = self.ddr3_read(address)
        if offset + len > self.BURST_LEN:
            data = np.append(data, self.ddr3_read(address + self.BURST_LEN))

        result = data[offset:offset + len]
        ans = 0
        for i in range(len):
            ans = ans | (result[i] << (i * 8))

        return ans

    def write(self, address, data, len):
        offset = address & self.BURST_MASK
        mask = np.zeros(self.BURST_LEN, dtype=np.uint8)
        mask[offset:offset + len] = 1
        self.ddr3_write(address, data, mask)
        if offset + len > self.BURST_LEN:
            mask = np.zeros(self.BURST_LEN, dtype=np.uint8)
            mask[0:offset + len - self.BURST_LEN] = 1
            self.ddr3_write(address + self.BURST_LEN, data, mask)

    def load_file(self, filepath, address):
        file = np.fromfile(filepath, dtype=np.uint8)
        rank, bank, row, col = self.resolve_dram_address(address)
        rank_idx, bank_idx, row_idx, col_idx = rank, bank, row, col
        for i in range(len(file)):
            self.__memory[rank_idx, bank_idx, row_idx, col_idx] = file[i]
            col_idx += 1
            if col_idx == self.NR_COL:
                col_idx = 0
                row_idx += 1
                if row_idx == self.NR_ROW:
                    row_idx = 0
                    bank_idx += 1
                    if bank_idx == self.NR_BANK:
                        bank_idx = 0
                        rank_idx += 1
                        if rank_idx == self.NR_RANK:
                            rank_idx = 0
