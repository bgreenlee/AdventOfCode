import sys
from itertools import pairwise
from typing import Callable

Point = tuple[int, int]

def display(rocks: set[Point], sand: set[Point]):
    min_x, min_y = min(p[0] for p in rocks), 0
    max_x, max_y = max(p[0] for p in rocks), max(p[1] for p in rocks)
    start = (500, 0)
    for y in range(min_y, max_y + 1):
        for x in range(min_x, max_x + 1):
            c = '.'
            if (x, y) in rocks:
                c = '#'
            elif (x, y) in sand:
                c = 'o'
            elif (x, y) == start:
                c = '+'
            print(c, end='')
        print()


def parse_input(lines: list[str]) -> set[Point]:
    rocks = set[Point]()
    for line in lines:
        points = [(int(x), int(y)) for x, y in [point.split(",") for point in line.split(" -> ")]]
        for a, b in pairwise(points):
            xrange = range(a[0], b[0] + 1) if a[0] < b[0] else range(b[0], a[0] + 1)
            for x in xrange:
                yrange = range(a[1], b[1] + 1) if a[1] < b[1] else range(b[1], a[1] + 1)
                for y in yrange:
                    rocks.add((x, y))

    return rocks


def solve(rocks: set[Point], has_floor: bool) -> set[Point]:
    sand = set[Point]()
    start = (500, 0)
    max_y = max(p[1] for p in rocks)
    floor_y = max_y + 2
    is_blocked: Callable[[Point], bool] = lambda p: p in sand or p in rocks or p[1] == floor_y

    sx, sy = start
    while (has_floor and not start in sand) or (not has_floor and sy < max_y):
        sy += 1
        if is_blocked((sx, sy)): # below
            if is_blocked((sx - 1, sy)): # diagonal left
                if is_blocked((sx + 1, sy)): # diagonal right
                    sand.add((sx, sy - 1))
                    sx, sy = start
                    continue
                else:
                    sx += 1 # flow right
            else:
                sx -= 1 # flow left

    return sand

#
# main
#

lines = [line.rstrip() for line in sys.stdin]
rocks = parse_input(lines)

sand = solve(rocks, False)
# display(rocks, sand)
print("Part 1:", len(sand))

sand = solve(rocks, True)
# display(rocks, sand)
print("Part 2:", len(sand))
