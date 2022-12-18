import sys
from collections import deque

Point = tuple[int, int, int]

def neighbors(points: set[Point], point: Point) -> list[Point]:
    x, y, z = point
    return [p for p in [(x + dx, y + dy, z + dz)
            for dx, dy, dz in [(0,0,1), (0,1,0), (1,0,0), (0,0,-1), (0,-1,0), (-1,0,0)]]
            if p in points]

def part1(points: set[Point]) -> int:
    covered = sum(len(neighbors(points, point)) for point in points)
    return len(points) * 6 - covered

def part2(points: set[Point]) -> int:
    x_min, x_max = min(p[0] for p in points), max(p[0] for p in points)
    y_min, y_max = min(p[1] for p in points), max(p[1] for p in points)
    z_min, z_max = min(p[2] for p in points), max(p[2] for p in points)

    def flood_fill(point: Point) -> set[Point]:
        flooded = set[Point]()
        queue = deque[Point]()

        queue.append(point)
        while len(queue) > 0:
            x, y, z = p = queue.popleft()
            if p not in points and p not in flooded and x_min - 1 <= x <= x_max + 1 and y_min - 1 <= y <= y_max + 1 and z_min - 1 <= z <= z_max + 1:
                flooded.add(p)
                queue.extend((x + dx, y + dy, z + dz) for dx, dy, dz in [(0,0,1), (0,1,0), (1,0,0), (0,0,-1), (0,-1,0), (-1,0,0)])

        return flooded

    flooded = flood_fill((x_min - 1, y_min - 1, z_min - 1))
    exterior = sum(len(neighbors(points, point)) for point in flooded)
    return exterior

#
# main
#

lines = [line.rstrip() for line in sys.stdin]
points = set(tuple([int(n) for n in line.split(",")]) for line in lines)

print("Part 1:", part1(points))
print("Part 2:", part2(points))