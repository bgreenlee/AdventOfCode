import sys
from functools import cmp_to_key

# sort function for packets
# returns -1 if left < right, 1 if left > right, 0 if equal
def packet_order(a: list|int, b: list|int) -> int:
    match a, b:
        case list(), list():
            for i in range(len(a)):
                if i >= len(b):
                    return 1 # no more right
                if (order := packet_order(a[i], b[i])) != 0:
                    return order
            return -1
        case list(), int():
            return packet_order(a, [b])
        case int(), list():
            return packet_order([a], b)
        case int(), int():
            return (a > b) - (a < b) # cmp


def part1(packets: list) -> int:
    ordered = [packet_order(a, b) for a, b in zip(packets[::2], packets[1::2])]
    return sum([i+1 for i, o in enumerate(ordered) if o == -1])


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

    