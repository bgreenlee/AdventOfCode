import sys
    
def cycleAndSum(cycle, x, sum):
    cycle += 1
    if cycle in [20, 60, 100, 140, 180, 220]:
        sum += cycle * x
    return cycle, x, sum


def part1(commands) -> int:
    cycle = 0
    x = 1
    sum = 0

    for cmd in commands:
        cycle, x, sum = cycleAndSum(cycle, x, sum)
        match cmd.split():
            case ["addx", val]:
                cycle, x, sum = cycleAndSum(cycle, x, sum)
                x += int(val)

    return sum


def cycleAndRender(cycle, x) -> int:
    print('#' if abs(x - cycle % 40) < 2 else ' ', end='')

    cycle += 1
    if cycle % 40 == 0:
        print()

    return cycle


def part2(commands):
    cycle = 0
    x = 1

    for cmd in commands:
        cycle = cycleAndRender(cycle, x)
        match cmd.split():
            case ["addx", val]:
                cycle = cycleAndRender(cycle, x)
                x += int(val)


#
# main
#
commands = [line.rstrip() for line in sys.stdin]
print("Part 1: ", part1(commands))
print("Part 2:")
part2(commands)