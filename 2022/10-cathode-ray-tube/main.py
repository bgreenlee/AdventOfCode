import sys
from collections.abc import Callable
from typing import Self


class Cpu:
    Callback = Callable[[Self], None]
    x = 1
    cycle = 0
    callbacks: list[Callback] = []

    def registerCallback(self, callback: Callback):
        self.callbacks.append(callback)

    def tick(self):
        self.cycle += 1

        for callback in self.callbacks:
            callback(self)

    def run(self, commands: list[str]):
        for cmd in commands:
            self.tick()
            match cmd.split():
                case ["addx", val]:
                    self.tick()
                    self.x += int(val)


def part1(commands: list[str]) -> int:
    total = 0

    def sumCycles(cpu: Cpu):
        nonlocal total
        if cpu.cycle % 40 == 20:
            total += cpu.cycle * cpu.x

    cpu = Cpu()
    cpu.registerCallback(sumCycles)
    cpu.run(commands)

    return total


def part2(commands: list[str]):
    def renderPixel(cpu: Cpu):
        print('#' if abs(cpu.x - (cpu.cycle - 1) % 40) < 2 else ' ', end='')
        if cpu.cycle % 40 == 0:
            print()

    cpu = Cpu()
    cpu.registerCallback(renderPixel)
    cpu.run(commands)


# main
commands = [line.rstrip() for line in sys.stdin]

print("Part 1: ", part1(commands))
print("Part 2:")
part2(commands)
