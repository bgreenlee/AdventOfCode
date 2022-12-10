import sys
from collections.abc import Callable
from typing import Self


class Cpu:
    Callback = Callable[[Self], None]
    x = 1
    cycle = 0

    def run(self, commands: list[str]):
        for cmd in commands:
            self.cycle += 1
            yield self
            match cmd.split():
                case ["addx", val]:
                    self.cycle += 1
                    yield self
                    self.x += int(val)


def part1(commands: list[str]) -> int:
    cpu = Cpu()
    total = 0
    for runtime in cpu.run(commands):
        if runtime.cycle % 40 == 20:
            total += runtime.cycle * runtime.x

    return total


def part2(commands: list[str]):
    cpu = Cpu()
    for runtime in cpu.run(commands):
        print('#' if abs(runtime.x - (runtime.cycle - 1) % 40) < 2 else ' ', end='')
        if runtime.cycle % 40 == 0:
            print()


# main
commands = [line.rstrip() for line in sys.stdin]

print("Part 1: ", part1(commands))
print("Part 2:")
part2(commands)
