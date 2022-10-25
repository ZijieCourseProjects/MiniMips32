import sys

from PyQt6.QtGui import QFont
from PyQt6.QtWidgets import QApplication, QMainWindow, QLabel, QVBoxLayout, QWidget
from PyQt6.QtWidgets import QStyleFactory

from CPU import CPU
from Debugger import compute
from RegList import RegList
from ui import Ui_MainWindow


class InstrDisp(QLabel):
    def __init__(self, text, cpu, address):

        super().__init__(text)
        self.cpu = cpu
        self.setFixedHeight(30)
        self.address = address
        self.have_breakpoint = False
        self.breakpoint_id = None
        self.reset_style()

    def mouseDoubleClickEvent(self, event):
        if not self.have_breakpoint:
            self.add_broder()
            self.breakpoint_id = self.cpu.set_watchpoint("$pc==" + hex(self.address))
            self.have_breakpoint = True
        else:
            self.have_breakpoint = False
            self.cpu.remove_watchpoint(self.breakpoint_id)
            self.reset_style()

    def reset_style(self):
        self.setStyleSheet("background-color: #000000; color: #ffffff;border: 1px solid #000000;")
        if self.cpu[RegList.PC.value].low32 == self.address:
            self.red()
        if self.have_breakpoint:
            self.add_broder()

    def red(self):
        style = self.styleSheet()
        self.setStyleSheet(style + "background-color: rgb(255, 0, 0);")

    def add_broder(self):
        style = self.styleSheet()
        self.setStyleSheet(style + "border: 1px solid red;")


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.cpu = CPU()
        self.to_read_addr = self.cpu.ENTRY_START
        self.cpu.load_file(sys.argv[1], sys.argv[2])
        self.cpu.fetch_all_instruction()
        self.widget = QWidget()
        self.vbox = QVBoxLayout()
        self.inst_map = {}
        self.__consoleoutput = 'Welcome to the MIPS Simulator!\n'

        for pc, instr in self.cpu.instrs.items():
            inst_show = InstrDisp(str(hex(pc)) + ": " + str(instr), self.cpu, pc)
            self.vbox.addWidget(inst_show)
            self.inst_map[pc] = inst_show

        self.widget.setLayout(self.vbox)
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        self.ui.scrollArea.setWidget(self.widget)
        self.ui.step.clicked.connect(self.step_pressed)
        self.ui.reset.clicked.connect(self.reset_pressed)
        self.ui.run.clicked.connect(self.run_pressed)
        self.ui.console_input.returnPressed.connect(self.console_pressed)
        self.ui.console.setText(self.__consoleoutput)
        self.ui.console.setFont(QFont("Courier New", 15))
        self.ui.memread.setText("MemoryView")
        self.ui.memread.setFont(QFont("Courier New", 15))
        self.ui.memaddr.returnPressed.connect(self.scan_memory)
        self.__prev_high = self.cpu.ENTRY_START
        self.__eval_id = 0
        self.update_items()

    def console_print(self, message):
        self.__consoleoutput += message
        self.ui.console.setText(self.__consoleoutput)
        self.ui.console.verticalScrollBar().setValue(self.ui.console.verticalScrollBar().maximum())

    def console_pressed(self):
        input_text = self.ui.console_input.text()
        self.ui.console_input.setText("")
        self.console_print(f"input [{self.__eval_id}]:  {input_text}\n")
        if input_text[0] == 'w':
            watchpoint_id = self.cpu.set_watchpoint(input_text[1:len(input_text)])
            result = f"Watchpoint {watchpoint_id} set at{input_text[1:len(input_text)]}"
        elif input_text[0] == 'p' and len(input_text) > 2:
            result = hex(compute(self.cpu, input_text[1:len(input_text)]))
        elif input_text[0] == 'd':
            self.cpu.remove_watchpoint(int(input_text[1:len(input_text)]))
            result = f"Watchpoint{input_text[1:len(input_text)]} removed"
        elif input_text == 'gold':
            self.export_golden_trace()
            result = "Golden trace exported to golden_trace.txt"
        else:
            result = "Invalid command"
        self.console_print(f"output[{self.__eval_id}]:  {result}\n")
        self.__eval_id += 1
        self.console_print("\n")

    def update_items(self):
        self.update_highlight()
        self.update_register()
        self.update_read_result()

    def update_register(self):
        registers, cp0 = self.cpu.registers()
        # PC AT V0 V1 A0 A1 A2 A3 T0 T1 T2 T3 T4 T5 T6 T7 S0 S1 S2 S3 S4 S5 S6 S7 T8 T9 K0 K1 GP SP FP RA
        self.ui.PC.setText("PC: " + hex(registers[RegList.PC.value].low32))
        self.ui.AT.setText("AT: " + hex(registers[RegList.AT.value].low32))
        self.ui.V0.setText("V0: " + hex(registers[RegList.V0.value].low32))
        self.ui.V1.setText("V1: " + hex(registers[RegList.V1.value].low32))
        self.ui.A0.setText("A0: " + hex(registers[RegList.A0.value].low32))
        self.ui.A1.setText("A1: " + hex(registers[RegList.A1.value].low32))
        self.ui.A2.setText("A2: " + hex(registers[RegList.A2.value].low32))
        self.ui.A3.setText("A3: " + hex(registers[RegList.A3.value].low32))
        self.ui.T0.setText("T0: " + hex(registers[RegList.T0.value].low32))
        self.ui.T1.setText("T1: " + hex(registers[RegList.T1.value].low32))
        self.ui.T2.setText("T2: " + hex(registers[RegList.T2.value].low32))
        self.ui.T3.setText("T3: " + hex(registers[RegList.T3.value].low32))
        self.ui.T4.setText("T4: " + hex(registers[RegList.T4.value].low32))
        self.ui.T5.setText("T5: " + hex(registers[RegList.T5.value].low32))
        self.ui.T6.setText("T6: " + hex(registers[RegList.T6.value].low32))
        self.ui.T7.setText("T7: " + hex(registers[RegList.T7.value].low32))
        self.ui.S0.setText("S0: " + hex(registers[RegList.S0.value].low32))
        self.ui.S1.setText("S1: " + hex(registers[RegList.S1.value].low32))
        self.ui.S2.setText("S2: " + hex(registers[RegList.S2.value].low32))
        self.ui.S3.setText("S3: " + hex(registers[RegList.S3.value].low32))
        self.ui.S4.setText("S4: " + hex(registers[RegList.S4.value].low32))
        self.ui.S5.setText("S5: " + hex(registers[RegList.S5.value].low32))
        self.ui.S6.setText("S6: " + hex(registers[RegList.S6.value].low32))
        self.ui.S7.setText("S7: " + hex(registers[RegList.S7.value].low32))
        self.ui.T8.setText("T8: " + hex(registers[RegList.T8.value].low32))
        self.ui.T9.setText("T9: " + hex(registers[RegList.T9.value].low32))
        self.ui.K0.setText("K0: " + hex(registers[RegList.K0.value].low32))
        self.ui.K1.setText("K1: " + hex(registers[RegList.K1.value].low32))
        self.ui.GP.setText("GP: " + hex(registers[RegList.GP.value].low32))
        self.ui.SP.setText("SP: " + hex(registers[RegList.SP.value].low32))
        self.ui.FP.setText("FP: " + hex(registers[RegList.FP.value].low32))
        self.ui.RA.setText("RA: " + hex(registers[RegList.RA.value].low32))
        self.ui.ZERO.setText("ZERO: 0x0")
        self.ui.EPC.setText("EPC: " + hex(cp0[RegList.EPC].low32))
        self.ui.CAUSE.setText("CAUSE: " + hex(cp0[RegList.CAUSE].low32))
        self.ui.STATUS.setText("STATUS: " + hex(cp0[RegList.STATUS].low32))
        self.ui.HI.setText("HI: " + hex(registers[RegList.HI].low32))
        self.ui.LO.setText("LO: " + hex(registers[RegList.LO].low32))

    def export_golden_trace(self):
        golden_trace = self.cpu.get_golden_trace()
        with open("golden_trace.txt", "w") as f:
            for pc, regid, value in golden_trace:
                f.write(f"{pc:#0{10}x} {regid:02} {value: #0{10}x}\n")

    def reset_pressed(self):
        self.cpu.reset()
        self.update_items()

    def update_read_result(self):
        output = ''
        for i in range(15):
            data = self.cpu.mem.read(self.to_read_addr + 4 * i, 4)
            output += f'{hex(self.to_read_addr + 4 * i)}: {data:#0{10}x}\n'
        self.ui.memread.setText(output)

    def scan_memory(self):
        self.to_read_addr = compute(self.cpu, self.ui.memaddr.text())
        self.ui.memaddr.setText('')
        self.update_read_result()

    def update_highlight(self):
        self.inst_map[self.__prev_high].reset_style()
        self.inst_map[self.cpu[RegList.PC].low32].red()
        self.__prev_high = self.cpu[RegList.PC].low32
        self.ui.scrollArea.verticalScrollBar().setValue(
            self.inst_map[self.cpu[RegList.PC].low32].pos().y() - 6 * self.inst_map[
                self.cpu[RegList.PC].low32].height())

    def run_pressed(self):
        self.cpu.run()
        self.update_items()

    def step_pressed(self):
        try:
            print(self.cpu.step())
            self.update_items()
        except KeyError:
            print("Error: Invalid instruction at PC: " + hex(self.cpu[RegList.PC].low32))


if __name__ == '__main__':
    # print('''
    # Welcome to the MIPS Simulator!
    #     ########  ##    ## ######## ######## ##     ## ##     ##
    #     ##     ##  ##  ##     ##    ##       ##   ### ##     ##
    #     ##     ##   ####      ##    ##       #### #### ##     ##
    #     ########     ##       ##    ######   ## ### ## ##     ##
    #     ##           ##       ##    ##       ##     ## ##     ##
    #     ##           ##       ##    ##       ##     ## ##     ##
    #     ##           ##       ##    ######## ##     ##  #######
    # ''')
    #
    # print('Initializing virtual machine..')
    # cpu = CPU()
    #
    # print('Loading files..')
    # print(f'instr_file: {sys.argv[1]}')
    # print(f'data_file: {sys.argv[2]}')
    #
    # cpu.load_file(sys.argv[1], sys.argv[2])

    app = QApplication([])
    app.setStyle(QStyleFactory.create('Fusion'))
    window = MainWindow()
    window.show()
    app.exec()

    # try:
    #     while True:
    #         cmd = input("TEMU >> ")
    #         if cmd == 'r':
    #             cpu.run()
    #         elif cmd == 's':
    #             in_print(cpu.step())
    #         elif cmd == 'p':
    #             cpu.print_registers()
    #         elif cmd[0] == 'w':
    #             cpu.set_watchpoint(cmd[1:len(cmd)])
    #         elif cmd[0] == 'p' and len(cmd) > 2:
    #             compute(cpu, cmd[1:len(cmd)])
    #         elif cmd[0] == 'd':
    #             cpu.remove_watchpoint(int(cmd[1:len(cmd)]))
    #         elif cmd[0] == 'x':
    #             in_print(read_memory(cpu, cmd[2:len(cmd)]))
    #         elif cmd == 'gold':
    #             cpu.print_golden_trace()
    #         else:
    #             in_print('Unknown command')
    #
    # except KeyboardInterrupt:
    #     print('Exiting..')
    #     sys.exit(0)
