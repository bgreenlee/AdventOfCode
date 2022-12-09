import sys
import math

Point = tuple[int, int]

def adjacent(a: Point, b: Point) -> bool:
    return abs(a[0] - b[0]) <= 1 and abs(a[1] - b[1]) <= 1

def sign(num: int) -> int:
    return int(math.copysign(1, num))

def move_tail(h_pos: Point, t_pos: Point) -> tuple[Point, set[Point]]:
    t_visited = set()

    if adjacent(h_pos, t_pos):
        return t_pos, t_visited

    x_dist = h_pos[0] - t_pos[0]
    y_dist = h_pos[1] - t_pos[1]

    if x_dist == 0: # same col
        while not adjacent(h_pos, t_pos):
            t_pos = (t_pos[0], t_pos[1] + sign(y_dist))
            t_visited.add(t_pos)
        return t_pos, t_visited

    if y_dist == 0: # same row
        while not adjacent(h_pos, t_pos):
            t_pos = (t_pos[0] + sign(x_dist), t_pos[1])
            t_visited.add(t_pos)
        return t_pos, t_visited

    # if not in the same col or row, move diagonal first
    # should never be more than one row or column away
    t_pos = (t_pos[0] + sign(x_dist), t_pos[1] + sign(y_dist))
    t_visited.add(t_pos)
    t_pos, more_t_visted = move_tail(h_pos, t_pos)
    t_visited |= more_t_visted
    return t_pos, t_visited


def part1(moves: list[tuple[str, int]]) -> int:
    h_pos = (0,0)
    t_pos = (0,0)
    t_visited = set()

    for m in moves:
        match m:
            case ['R', steps]:
                h_pos = (h_pos[0] + steps, h_pos[1])
            case ['L', steps]:
                h_pos = (h_pos[0] - steps, h_pos[1])
            case ['U', steps]:
                h_pos = (h_pos[0], h_pos[1] + steps)
            case ['D', steps]:
                h_pos = (h_pos[0], h_pos[1] - steps)

        t_pos, visited = move_tail(h_pos, t_pos)
        t_visited |= visited

    return len(t_visited)


def part2(moves: list[tuple[str, int]], size: int) -> int:
    segments = [(0,0)] * size
    t_visited = set([(0,0)])

    for m in moves:
        for i in range(size-1):
            match m:
                case ['R', steps]:
                    segments[i] = (segments[i][0] + steps, segments[i][1])
                case ['L', steps]:
                    segments[i] = (segments[i][0] - steps, segments[i][1])
                case ['U', steps]:
                    segments[i] = (segments[i][0], segments[i][1] + steps)
                case ['D', steps]:
                    segments[i] = (segments[i][0], segments[i][1] - steps)

            segments[i+1], visited = move_tail(segments[i], segments[i+1])
            if i == size - 2: # only update t_visited for the tail
                t_visited |= visited

    return len(t_visited)

#
# main
#
moves = []
for line in sys.stdin:
    direction, steps = line.rstrip().split()
    moves.append((direction, int(steps)))

print("Part 1: %d" % part2(moves, 2))
print("Part 2: %d" % part2(moves, 10))
