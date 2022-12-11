import sys
import re
from dataclasses import dataclass
from collections import deque
from functools import reduce
from copy import deepcopy

@dataclass
class Monkey:
    id: int
    items: deque[int]
    op: str
    operand: str
    test: int
    if_true: int
    if_false: int
    inspect_count: int = 0

    def inspect_item(self, item: int, divisor: int, modulo: int) -> tuple[int, int]:
        self.inspect_count += 1
        scalar = item if self.operand == "old" else int(self.operand)
        worry_level = 0
        match self.op:
            case '+':
                worry_level = item + scalar
            case '*':
                worry_level = item * scalar

        worry_level //= divisor
        worry_level %= modulo
        return worry_level, self.if_true if worry_level % self.test == 0 else self.if_false

def solve(monkies: list[Monkey], num_rounds: int, divisor: int = 1) -> int:
    monkies = deepcopy(monkies) # so we don't modify the original
    modulo = reduce(lambda x, y: x * y, [m.test for m in monkies]) # product of all the divisor tests
    for round in range(num_rounds):
        for monkey in monkies:
            while monkey.items:
                item = monkey.items.popleft()
                new_item, dest = monkey.inspect_item(item, divisor, modulo)
                monkies[dest].items.append(new_item)

    monkies.sort(key=lambda m: m.inspect_count, reverse=True)
    return monkies[0].inspect_count * monkies[1].inspect_count

#
# main
#
monkies: list[Monkey] = []

data = sys.stdin.read()
monkey_re = re.compile(r"""
        Monkey\ (?P<id>\d+):\n
        \s+Starting\ items:\ (?P<items>[\d, ]+)\n
        \s+Operation:\ new\ =\ old\ (?P<op>.)\ (?P<operand>\w+)\n
        \s+Test:\ divisible\ by\ (?P<test>\d+)\n
        \s+If\ true:\ throw\ to\ monkey\ (?P<if_true>\d+)\n
        \s+If\ false:\ throw\ to\ monkey\ (?P<if_false>\d+)""", re.X)

for m in monkey_re.finditer(data):
    monkey = Monkey(id=int(m.group('id')),
                    items=deque([int(i) for i in m.group('items').split(', ')]),
                    op=m.group('op'),
                    operand=m.group('operand'),
                    test=int(m.group('test')),
                    if_true=int(m.group('if_true')),
                    if_false=int(m.group('if_false')))
    monkies.append(monkey)

print("Part 1:", solve(monkies, 20, 3))
print("Part 2:", solve(monkies, 10000))
