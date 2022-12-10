import sys

Point = tuple[int, int]

# return true if the two points are adjacent
def adjacent(a: Point, b: Point) -> bool:
    return abs(a[0] - b[0]) <= 1 and abs(a[1] - b[1]) <= 1

# return the sign (-1, 0, or 1) of the given number
def sign(n: int) -> int:
    return (n > 0) - (n < 0)

# move the "tail" to be adjacent to the head, one step at a time
# return the new tail position and a set of all points visited by the tail in the move
def move(head: Point, tail: Point) -> tuple[Point, set[Point]]:
    visited = set([tail])

    while not adjacent(head, tail):
        dx, dy = head[0] - tail[0], head[1] - tail[1]
        tail = (tail[0] + sign(dx), tail[1] + sign(dy))
        visited.add(tail)

    return tail, visited

# print out the visited points
def display(points: set[Point]):
    min_x, min_y = min(p[0] for p in points), min(p[1] for p in points)
    max_x, max_y = max(p[0] for p in points), max(p[1] for p in points)
    for y in range(min_y, max_y + 1):
        for x in range(min_x, max_x + 1):
            if (x, y) in points:
                print('#', end='')
            else:
                print('.', end='')
        print()

def solve(moves: list[tuple[str, int]], size: int) -> int:
    start = (0, 0)
    segments = [start] * size
    visited = set([start])
    stepdir = {'R': (1, 0), 'L': (-1, 0), 'D': (0, 1), 'U': (0, -1)}

    for direction, steps in moves:
        for _ in range(steps):            
            # move head
            segments[0] = (segments[0][0] + stepdir[direction][0], segments[0][1] + stepdir[direction][1])
            # move the rest of the body
            for j in range(size-1):
                segments[j+1], v = move(segments[j], segments[j+1])
            visited |= v  # only update for tail

    display(visited)
    return len(visited)

#
# main
#
moves = []
for line in sys.stdin:
    direction, steps = line.rstrip().split()
    moves.append((direction, int(steps)))

print("Part 1: %d" % solve(moves, 2))
print("Part 2: %d" % solve(moves, 10))
