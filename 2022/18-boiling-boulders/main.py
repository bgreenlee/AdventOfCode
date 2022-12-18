import sys
from collections import deque

Point = tuple[int, int, int]

# adjacent coordinates
def adjacent(p: Point) -> list[Point]:
    return [(p[0] + dx, p[1] + dy, p[2] + dz) for dx, dy, dz in [(0,0,1), (0,1,0), (1,0,0), (0,0,-1), (0,-1,0), (-1,0,0)]]

# populated adjacent points
def neighbors(points: set[Point], point: Point) -> list[Point]:
    return [p for p in adjacent(point) if p in points]

# count all open surfaces
def part1(points: set[Point]) -> int:
    return len(points) * 6 - sum(len(neighbors(points, point)) for point in points)

# count all exterior surfaces
def part2(points: set[Point]) -> int:
    # create a bounding box around the points and flood fill the interior

    # bounding box
    x_min, x_max = min(p[0] for p in points) - 1, max(p[0] for p in points) + 1
    y_min, y_max = min(p[1] for p in points) - 1, max(p[1] for p in points) + 1
    z_min, z_max = min(p[2] for p in points) - 1, max(p[2] for p in points) + 1

    # flood fill
    flooded = set[Point]()
    queue = deque([(x_min, y_min, z_min)]) # start in corner of bounding box
    while len(queue) > 0:
        x, y, z = p = queue.popleft()
        if p not in points and p not in flooded and x_min <= x <= x_max and y_min <= y <= y_max and z_min <= z <= z_max:
            flooded.add(p)
            queue.extend(adjacent(p))

    return sum(len(neighbors(points, point)) for point in flooded)

#
# main
#

lines = [line.rstrip() for line in sys.stdin]
points = set(tuple([int(n) for n in line.split(",")]) for line in lines)

print("Part 1:", part1(points))
print("Part 2:", part2(points))