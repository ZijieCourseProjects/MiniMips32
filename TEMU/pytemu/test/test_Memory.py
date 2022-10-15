import Memory
from unittest import TestCase


class Test_Memory(TestCase):

    def test_readwrite(self):
        mem = Memory.Memory()
        for i in range(10000):
            mem.write(0x80000000 + i, 0x12, 1)
            self.assertEqual(hex(mem.read(0x80000000 + i, 1)), hex(0x12),
                             'write 0x12 to 0x80000000 + %d, but read 0x%x' % (i, mem.read(0x80000000 + i, 1)))
            mem.write(0x80000000 + i, 0x12, 2)
            self.assertEqual(hex(mem.read(0x80000000 + i, 2)), hex(0x12),
                             'write 0x12 to 0x80000000 + %d, but read 0x%x' % (i, mem.read(0x80000000 + i, 1)))
            mem.write(0x80000000 + i, 0x12, 4)
            self.assertEqual(hex(mem.read(0x80000000 + i, 4)), hex(0x12),
                             'write 0x12 to 0x80000000 + %d, but read 0x%x' % (i, mem.read(0x80000000 + i, 1)))
            mem.write(0x80000000 + i, 0x1234, 2)
            self.assertEqual(hex(mem.read(0x80000000 + i, 2)), hex(0x1234),
                             'write 0x1234 to 0x80000000 + %d, but read 0x%x' % (i, mem.read(0x80000000 + i, 2)))
            mem.write(0x80000000 + i, 0x1234, 4)
            self.assertEqual(hex(mem.read(0x80000000 + i, 4)), hex(0x1234),
                             'write 0x1234 to 0x80000000 + %d, but read 0x%x' % (i, mem.read(0x80000000 + i, 2)))
            mem.write(0x80000000 + i, 0x12345678, 4)
            self.assertEqual(hex(mem.read(0x80000000 + i, 4)), hex(0x12345678),
                             'write 0x12345678 to 0x80000000 + %d, but read 0x%x' % (i, mem.read(0x80000000 + i, 4)))
