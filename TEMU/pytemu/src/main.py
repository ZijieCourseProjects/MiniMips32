import sys

from CPU import CPU
from Debugger import compute, read_memory
from util import in_print

if __name__ == '__main__':
    print('''
    Welcome to the MIPS Simulator!
        ########  ##    ## ######## ######## ##     ## ##     ## 
        ##     ##  ##  ##     ##    ##       ##   ### ##     ## 
        ##     ##   ####      ##    ##       #### #### ##     ## 
        ########     ##       ##    ######   ## ### ## ##     ## 
        ##           ##       ##    ##       ##     ## ##     ## 
        ##           ##       ##    ##       ##     ## ##     ## 
        ##           ##       ##    ######## ##     ##  #######  
    ''')

    print('Initializing virtual machine..')
    cpu = CPU()

    print('Loading files..')
    print(f'instr_file: {sys.argv[1]}')
    print(f'data_file: {sys.argv[2]}')

    cpu.load_file(sys.argv[1], sys.argv[2])

    try:
        while True:
            cmd = input("TEMU >> ")
            if cmd == 'r':
                cpu.run()
            elif cmd == 's':
                in_print(cpu.step())
            elif cmd == 'p':
                cpu.print_registers()
            elif cmd[0] == 'w':
                cpu.set_watchpoint(cmd[1:len(cmd)])
            elif cmd[0] == 'p' and len(cmd) > 2:
                compute(cpu, cmd[1:len(cmd)])
            elif cmd[0] == 'd':
                cpu.remove_watchpoint(int(cmd[1:len(cmd)]))
            elif cmd[0] == 'x':
                in_print(read_memory(cpu, cmd[2:len(cmd)]))
            elif cmd == 'gold':
                cpu.print_golden_trace()
            else:
                in_print('Unknown command')

    except KeyboardInterrupt:
        print('Exiting..')
        sys.exit(0)
