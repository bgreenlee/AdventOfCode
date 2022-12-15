import sys
import re

Point = tuple[int, int]

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
    print(f"Iterating from {min_x} to {max_x+1}...")
    for x in range(min_x, max_x + 1):
        for sensor, strength in sensors.items():
            if distance((x, row), sensor) <= strength and (x, row) not in beacons:
                total += 1
                break
    return total


lines = [line.rstrip() for line in sys.stdin]
sensors, beacons = parse_input(lines)
print("Part 1:", part1(sensors, beacons, 2000000))
