import sys
    
def part1(commands) -> int:
    def nextCycle(cycle, x, sum):
        cycle += 1
        if cycle in [20, 60, 100, 140, 180, 220]:
            sum += cycle * x
        return cycle, x, sum

    cycle = 0
    x = 1
    sum = 0

    for cmd in commands:
        cycle, x, sum = nextCycle(cycle, x, sum)
        match cmd.split():
            case ["addx", val]:
                cycle, x, sum = nextCycle(cycle, x, sum)
                x += int(val)

    return sum

def part2(commands):
    cycle = 0
    x = 1

    def nextCycle(cycle) -> int:
        if abs(x - (cycle % 40)) < 2:
            print('#', end='')
        else:
            print(' ', end='')
        
        cycle += 1
        if cycle % 40 == 0:
            print()

        return cycle


    for cmd in commands:
        cycle = nextCycle(cycle)
        match cmd.split():
            case ["addx", val]:
                cycle = nextCycle(cycle)
                x += int(val)


#
# main
#
commands = [line.rstrip() for line in sys.stdin]
print("Part 1: ", part1(commands))
print("Part 2:")
part2(commands)