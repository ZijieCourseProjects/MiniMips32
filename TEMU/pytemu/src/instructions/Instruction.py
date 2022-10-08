class Instruction:

    def execute(self, cpu):
        pass


def signed_extend(value, bits):
    sign_bit = 1 << (bits - 1)
    return (value & (sign_bit - 1)) - (value & sign_bit)
