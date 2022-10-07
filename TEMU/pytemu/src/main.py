from CPU import CPU
import sys
from util import in_print
from Debugger import compute, read_memory

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
                cpu.step()
            elif cmd == 'p':
                cpu.print_registers()
            elif cmd[0] == 'p' and len(cmd) > 2:
                compute(cpu, cmd[1:len(cmd)])
            elif cmd[0] == 'x':
                read_memory(cpu, cmd[2:len(cmd)])
            else:
                in_print('Unknown command')

    except KeyboardInterrupt:
        print('Exiting..')
        sys.exit(0)
