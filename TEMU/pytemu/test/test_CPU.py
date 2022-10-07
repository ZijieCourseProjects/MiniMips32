from unittest import TestCase

import CPU


class TestCPU(TestCase):
    def test_execute(self):
        cpu = CPU.CPU()
        cpu.load_file('/Users/higgs/tju_arch/TEMU/inst.bin', '/Users/higgs/tju_arch/TEMU/data.bin')
