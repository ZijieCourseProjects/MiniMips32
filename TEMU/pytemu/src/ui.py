from rich.align import Align
from rich.box import DOUBLE
from rich.console import RenderableType
from rich.panel import Panel
from rich.style import Style
from rich.text import Text
from textual import events
from textual.app import App
from textual.reactive import Reactive
from textual.widget import Widget
from textual.widgets import Button, ButtonPressed
from CPU import CPU
from Debugger import compute, read_memory


class TextBox(Widget):
    """A simple text box widget."""

    def __init__(self, text: str = "HELLOTESTETEATSEADWDAW", style: Style = "white on dark_blue"):
        super().__init__()
        self.text = text
        self.style = style

    text: Reactive[str] = Reactive("")

    def render(self) -> RenderableType:
        """Render the text box."""
        return Panel(
            Align.center(
                Text(self.text, style=self.style),
                vertical="middle",
            ),
            box=DOUBLE,
        )

    def update(self, text: str):
        self.text = text


class Submit(Button):
    clicked: Reactive[RenderableType] = Reactive(False)

    def on_click(self) -> None:
        self.clicked = True


class InputText(Widget):
    title: Reactive[RenderableType] = Reactive("")
    content: Reactive[RenderableType] = Reactive("")
    mouse_over: Reactive[RenderableType] = Reactive(False)

    def __init__(self, title: str):
        super().__init__(title)
        self.title = title

    def on_enter(self) -> None:
        self.mouse_over = True

    def set_environ(self, cpu, result_box):
        self.cpu = cpu
        self.result_box = result_box

    def on_leave(self) -> None:
        self.mouse_over = False

    def on_key(self, event: events.Key) -> None:
        if self.mouse_over == True:
            if event.key == "ctrl+h":
                self.content = self.content[:-1]
            elif event.key == "enter":
                if self.content[0] == 'p' and len(self.content) > 2:
                    self.result_box.update(str(compute(self.cpu, self.content[1:len(self.content)])))
                elif self.content[0] == 'x':
                    self.result_box.update(read_memory(self.cpu, self.content[2:len(self.content)]))
                self.content = ""
                self.app.refresh()
            else:
                self.content += event.key

    def validate_title(self, value) -> None:
        try:
            return value.lower()
        except (AttributeError, TypeError):
            raise AssertionError("title attribute should be a string.")

    def render(self) -> RenderableType:
        renderable = None
        if self.title.lower() == "password":
            renderable = "".join(map(lambda char: "*", self.content))
        else:
            renderable = Align.left(Text(self.content, style="bold"))
        return Panel(
            renderable,
            title=self.title,
            title_align="center",
            height=3,
            style="bold white on rgb(50,57,50)",
            border_style=Style(color="green"),
            box=DOUBLE,
        )


class MainApp(App):
    submit: Reactive[RenderableType] = Reactive(False)
    username: Reactive[RenderableType] = Reactive("")
    password: Reactive[RenderableType] = Reactive("")

    def handle_button_pressed(self, message: ButtonPressed) -> None:
        """A message sent by the submit button"""
        assert isinstance(message.sender, Button)
        button_name = message.sender.name
        self.submit = message.sender.clicked
        if button_name == "submit" and self.submit:
            self.submit_button.clicked = False
            self.result_box.update(str(self.cpu.pre_fetch(5)))
            self.cpu.step()
            self.reg_box.update(self.cpu.print_registers_to_str())
            self.refresh()

    async def on_mount(self) -> None:
        self.cpu = CPU()
        self.cpu.load_file('/Users/higgs/tju_arch/TEMU/inst.bin', '/Users/higgs/tju_arch/TEMU/data.bin')
        self.submit_button = Submit(
            label="Submit", name="submit", style="black on white"
        )
        self.submit = self.submit_button.clicked
        self.input_box = InputText("command")
        self.result_box = TextBox(text="RESULT")
        self.reg_box = TextBox(text="Registers")
        self.eva_result = TextBox(text="EVA RESULT")
        self.input_box.set_environ(self.cpu, self.eva_result)
        self.reg_box.update(self.cpu.print_registers_to_str())
        await self.view.dock(self.result_box, self.reg_box, edge="top", size=15)
        await self.view.dock(self.submit_button, edge="bottom", size=3)
        await self.view.dock(self.input_box, self.eva_result, edge="bottom")


if __name__ == "__main__":
    MainApp.run(log="textual.log")
