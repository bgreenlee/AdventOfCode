import sys
import re

Point = tuple[int, int]
Interval = tuple[int, int]

def parse_input(lines: list[str]) -> tuple[dict[Point, int], set[Point]]:
    line_re = re.compile(r'Sensor at x=([-\d]+), y=([-\d]+): closest beacon is at x=([-\d]+), y=([-\d]+)')
    sensors: dict[Point, int] = {}
    beacons: set[Point] = set()
    for line in lines:
        if m := line_re.match(line):
            sx, sy = int(m.group(1)), int(m.group(2))
            bx, by = int(m.group(3)), int(m.group(4))
            sensors[(sx, sy)] = distance((sx, sy), (bx, by))
            beacons.add((bx, by))

    return sensors, beacons


# return Manhattan distance between two points
def distance(a: Point, b: Point) -> int:
    return abs(a[0] - b[0]) + abs(a[1] - b[1])


def part1(sensors: dict[Point, int], beacons: set[Point], row: int) -> int:
    min_x = min([p[0] - s for (p, s) in sensors.items()])
    max_x = max([p[0] + s for (p, s) in sensors.items()])
    total = 0

    for x in range(min_x, max_x + 1):
        for sensor, strength in sensors.items():
            if distance((x, row), sensor) <= strength and (x, row) not in beacons:
                total += 1
                break
    return total


# stolen from https://www.geeksforgeeks.org/merging-intervals/ because I'm lazy
def merge_intervals(intervals: list[Interval]) -> list[Interval]:
    if len(intervals) < 2:
        return intervals

    intervals.sort()
    stack = [intervals[0]]
    for i in intervals[1:]:
        if stack[-1][0] <= i[0] <= stack[-1][1] + 1:
            stack[-1] = (stack[-1][0], max(stack[-1][1], i[1]))
        else:
            stack.append(i)

    return stack


def part2(sensors: dict[Point, int], beacons: set[Point], max_xy: int) -> int:
    intervals: list[list[Interval]] = [[] for _ in range(max_xy + 1)]
    for sensor, strength in sensors.items():
        sx, sy = sensor
        min_y, max_y = max(0, sy - strength), min(max_xy, sy + strength)

        for y in range(min_y, max_y + 1):
            interval = (max(sx - strength + abs(sy - y), 0), min(sx + strength - abs(sy - y), max_xy))
            intervals[y] = merge_intervals([interval, *intervals[y]])

    # find the one row that has more than one interval
    for y, interval in enumerate(intervals):
        if len(interval) > 1:
            x = interval[0][1] + 1
            print(f"Part 2: beacon at ({x}, {y})")
            return x * 4000000 + y

    return 0


lines = [line.rstrip() for line in sys.stdin]
sensors, beacons = parse_input(lines)
print("Part 1:", part1(sensors, beacons, 2000000)) # test: 10
print("Part 2:", part2(sensors, beacons, 4000000)) # test: 20

