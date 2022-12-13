import sys

def is_ordered(left: list|int, right: list|int) -> bool|None:
    match left, right:
        case list(), list():
            for i, a in enumerate(left):
                if i >= len(right):
                    return False
                b = right[i]
                if (ordered := is_ordered(a, b)) != None:
                    return ordered
            return True
        case list(), int():
            return is_ordered(left, [right])
        case int(), list():
            return is_ordered([left], right)
        case int(), int():
            if left != right:
                return left < right

def part1(packets: list) -> int:
    ordered = [is_ordered(a, b) for a, b in zip(packets[::2], packets[1::2])]
    return sum([i+1 for i, b in enumerate(ordered) if b])

#
# main
#
packets = [eval(line.rstrip()) for line in sys.stdin if line != "\n"]

print("Part 1:", part1(packets))

    