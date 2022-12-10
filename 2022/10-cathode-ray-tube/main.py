import sys
from collections.abc import Callable
from typing import Self


class Cpu:
    Callback = Callable[[Self], None]
    x = 1
    cycle = 0
    precycleCallbacks: list[Callback] = []
    postcycleCallbacks: list[Callback] = []

    def registerPrecycleCallback(self, callback: Callback):
        self.precycleCallbacks.append(callback)

    def registerPostcycleCallback(self, callback: Callback):
        self.postcycleCallbacks.append(callback)

    def tick(self):
        for precycle in self.precycleCallbacks:
            precycle(self)

        self.cycle += 1

        for postcycle in self.postcycleCallbacks:
            postcycle(self)

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
    cpu.registerPostcycleCallback(sumCycles)
    cpu.run(commands)

    return total


def part2(commands):
    def renderPixel(cpu: Cpu):
        print('#' if abs(cpu.x - cpu.cycle % 40) < 2 else ' ', end='')
        if cpu.cycle % 40 == 39:
            print()

    cpu = Cpu()
    cpu.registerPrecycleCallback(renderPixel)
    cpu.run(commands)


# main
commands = [line.rstrip() for line in sys.stdin]

print("Part 1: ", part1(commands))
print("Part 2:")
part2(commands)
