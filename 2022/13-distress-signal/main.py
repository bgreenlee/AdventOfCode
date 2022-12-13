import sys
from functools import cmp_to_key

def packet_order(left: list|int, right: list|int) -> int:
    match left, right:
        case list(), list():
            for i, a in enumerate(left):
                if i >= len(right):
                    return 1
                b = right[i]
                if (ordered := packet_order(a, b)) != 0:
                    return ordered
            return -1
        case list(), int():
            return packet_order(left, [right])
        case int(), list():
            return packet_order([left], right)
        case int(), int():
            return (left > right) - (left < right) # cmp

def part1(packets: list) -> int:
    ordered = [packet_order(a, b) for a, b in zip(packets[::2], packets[1::2])]
    return sum([i+1 for i, b in enumerate(ordered) if b == -1])

def part2(packets: list) -> int:
    dividers = [[[2]],[[6]]]
    packets.extend(dividers)
    packets.sort(key=cmp_to_key(packet_order))
    return (packets.index(dividers[0]) +1 ) * (packets.index(dividers[1]) + 1)

#
# main
#

packets = [eval(line.rstrip()) for line in sys.stdin if line != "\n"]

print("Part 1:", part1(packets))
print("Part 2:", part2(packets))

    