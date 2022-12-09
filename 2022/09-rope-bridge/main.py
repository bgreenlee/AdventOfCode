import sys

# Point = tuple[int, int]
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __eq__(self, other):
        return self.x == other.x and self.y == other.y
    
    def __hash__(self):
        return hash((self.x, self.y))

    def __add__(self, other):
        return Point(self.x + other.x, self.y + other.y)

    def __repr__(self):
        return f"({self.x}, {self.y})"

# return true if the two points are adjacent
def adjacent(a: Point, b: Point) -> bool:
    return abs(a.x - b.x) <= 1 and abs(a.y - b.y) <= 1

# return the sign (-1, 0, or 1) of the given number
def sign(n: int) -> int:
    return (n > 0) - (n < 0)

# move the "tail" to be adjacent to the head, one step at a time
# return the new tail position and a set of all points visited by the tail in the move
def move(head: Point, tail: Point) -> tuple[Point, set[Point]]:
    visited = set([tail])

    while not adjacent(head, tail):
        dx, dy = head.x - tail.x, head.y - tail.y
        tail = Point(tail.x + sign(dx), tail.y + sign(dy))
        visited.add(tail)

    return tail, visited

# print out the visited points
def display(points: set[Point]):
    min_x, min_y = min(p.x for p in points), min(p.y for p in points)
    max_x, max_y = max(p.x for p in points), max(p.y for p in points)
    for y in range(min_y, max_y + 1):
        for x in range(min_x, max_x + 1):
            if Point(x, y) in points:
                print('#', end='')
            else:
                print('.', end='')
        print()


def solve(moves: list[tuple[str, int]], size: int) -> int:
    start = Point(0, 0)
    segments = [start] * size
    visited = set([start])
    stepdir = {'R': Point(1, 0), 'L': Point(-1, 0), 'D': Point(0, 1), 'U': Point(0, -1)}

    for direction, steps in moves:
        for i in range(steps):            
            # move head
            segments[0] += stepdir[direction]
            # move the rest of the body
            for i in range(size-1):
                segments[i+1], v = move(segments[i], segments[i+1])
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
