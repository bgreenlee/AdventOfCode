import sys
import re
import math
from dataclasses import dataclass
from collections import deque
from copy import deepcopy
from typing import Callable


@dataclass
class Monkey:
    items: deque[int]
    operation: Callable[[int], int]
    test: int
    if_true: int
    if_false: int
    inspect_count: int = 0

    def inspect_item(self, item: int, divisor: int, modulo: int) -> tuple[int, int]:
        self.inspect_count += 1
        worry_level = (self.operation(item) // divisor) % modulo
        return worry_level, self.if_true if worry_level % self.test == 0 else self.if_false


def parse_monkeys(data: str) -> list[Monkey]:
    monkey_re = re.compile(r"""Starting\ items:\ (?P<items>[\d, ]+)\n
            \s+Operation:\ new\ =\ (?P<operation>.*?)\n
            \s+Test:\ divisible\ by\ (?P<test>\d+)\n
            \s+If\ true:\ throw\ to\ monkey\ (?P<if_true>\d+)\n
            \s+If\ false:\ throw\ to\ monkey\ (?P<if_false>\d+)""", re.X)

    monkeys: list[Monkey] = []
    for m in monkey_re.finditer(data):
        monkey = Monkey(items=deque([int(i) for i in m.group('items').split(', ')]),
                        operation=eval(f"lambda old: {m.group('operation')}"), # kinda evil
                        test=int(m.group('test')),
                        if_true=int(m.group('if_true')),
                        if_false=int(m.group('if_false')))
        monkeys.append(monkey)

    return monkeys


def solve(monkeys: list[Monkey], num_rounds: int, divisor: int = 1) -> int:
    monkeys = deepcopy(monkeys)  # so we don't modify the original
    modulo = math.prod([m.test for m in monkeys]) # our modulus is the product of all the divisor tests
    for round in range(num_rounds):
        for monkey in monkeys:
            while monkey.items:
                item = monkey.items.popleft()
                new_item, dest = monkey.inspect_item(item, divisor, modulo)
                monkeys[dest].items.append(new_item)

    monkeys.sort(key=lambda m: m.inspect_count, reverse=True)
    return monkeys[0].inspect_count * monkeys[1].inspect_count


#
# main
#
monkeys = parse_monkeys(sys.stdin.read())
print("Part 1:", solve(monkeys, 20, 3))
print("Part 2:", solve(monkeys, 10000))
