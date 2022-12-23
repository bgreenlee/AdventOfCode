import sys
import re
from typing import NamedTuple
from enum import IntEnum


class Point(NamedTuple):
    x: int
    y: int


class CubePoint(NamedTuple):
    face: int
    x: int
    y: int


class Direction(IntEnum):
    Right = 0
    Down = 1
    Left = 2
    Up = 3

    def __add__(self, other):
        return Direction((self.value + other) % 4)

    def __sub__(self, other):
        return Direction((self.value - other) % 4)


Board = dict[Point, str]()
Move = int | str


def score(p, dir): return 1000 * (p.y + 1) + 4 * (p.x + 1) + dir.value


def part1(board: Board, max_x: int, max_y: int, moves: list[Move], start: Point) -> tuple[Point, Direction]:
    pos = start
    dir = Direction.Right
    for move in moves:
        match move:
            case 'R':
                dir += 1
            case 'L':
                dir -= 1
            case n:
                for i in range(n):
                    dx = 1 if dir == Direction.Right else -1 if dir == Direction.Left else 0
                    dy = 1 if dir == Direction.Down else -1 if dir == Direction.Up else 0
                    x, y = pos
                    while (next_pos := Point((x + dx) % max_x, (y + dy) % max_y)) not in board:
                        x += dx
                        y += dy
                    if board[next_pos] == '#':
                        break
                    pos = next_pos
    return pos, dir


def display(board: Board, pos: Point, dir: Direction):
    min_x, max_x = min(p.x for p in board.keys()), max(
        p.x for p in board.keys())
    min_y, max_y = min(p.y for p in board.keys()), max(
        p.y for p in board.keys())
    for y in range(min_y, max_y + 1):
        for x in range(min_x, max_x + 1):
            p = Point(x, y)
            if p == pos:
                print(['>', 'v', '<', '^'][dir], end='')
            else:
                print(board[p] if p in board else ' ', end='')
        print()


def part2(board: Board, max_x: int, max_y: int, moves: list[Move], start: CubePoint) -> tuple[Point, Direction]:
    size = int(max(max_x, max_y) / 4)  # cube size
    pos = start
    dir = Direction.Right

    # full input
    topology = [
        # face 0 connects to 1 on the right, 2 down, 3 left, 5 up with rotations 0,0,180,90
        [(1, 0), (2, 0), (3, 2), (5, 1)],
        [(4, 2), (2, 1), (0, 0), (5, 0)],
        [(1, 3), (4, 0), (3, 3), (0, 0)],
        [(4, 0), (5, 0), (0, 2), (2, 1)],
        [(1, 2), (5, 1), (3, 0), (2, 0)],
        [(4, 3), (1, 0), (0, 3), (3, 0)],
    ]
    # test input
    # topology = [
    #     [(5, 2), (3, 0), (2, 3), (1, 2)],
    #     [(2, 0), (4, 2), (5, 1), (0, 2)],
    #     [(3, 0), (4, 3), (1, 0), (0, 1)],
    #     [(5, 1), (4, 0), (2, 0), (3, 0)],
    #     [(5, 0), (1, 2), (2, 1), (3, 0)],
    #     [(0, 2), (1, 3), (4, 0), (3, 1)],
    # ]

    # translate a CubePoint to a Point on the board
    # mapping represents the x, y offsets (in units of `size`) for each face
    def cube_to_board(cp: CubePoint) -> Point:
        # full input
        mx, my = [(1, 0), (2, 0), (1, 1), (0, 2), (1, 2), (0, 3)][cp.face]
        # test input
        # mx, my = [(2, 0), (0, 1), (1, 1), (2, 1), (2, 2), (3, 2)][cp.face]

        return Point(cp.x + size * mx, cp.y + size * my)

    # rotate the point rotation * 90 degrees clockwise
    def rotate(cp: CubePoint, rotation: int) -> CubePoint:
        f, x, y = cp
        for i in range(rotation):
            x, y = size - y - 1, x
        return CubePoint(f, x, y)

    for move in moves:
        # display(board, cube_to_board(pos), dir)
        # print("Move:", move)
        match move:
            case 'R':
                dir += 1
            case 'L':
                dir -= 1
            case n:
                for i in range(n):
                    dx = 1 if dir == Direction.Right else -1 if dir == Direction.Left else 0
                    dy = 1 if dir == Direction.Down else -1 if dir == Direction.Up else 0
                    face, x, y = pos
                    rotation = 0
                    next_dir = dir
                    # if we're going off the edge, find our next cube and rotation
                    if x + dx < 0 or x + dx >= size or y + dy < 0 or y + dy >= size:
                        face, rotation = topology[face][dir]
                        next_dir += rotation
                    next_pos = rotate(CubePoint(face, (x + dx) %
                                      size, (y + dy) % size), rotation)
                    if board[cube_to_board(next_pos)] == '#':
                        break
                    pos = next_pos
                    dir = next_dir

    # display(board, cube_to_board(pos), dir)
    # print(pos, cube_to_board(pos), dir)
    return cube_to_board(pos), dir


board = dict[Point, str]()
moves = list[Move]()
start: Point = None

lines = sys.stdin.read().splitlines()
max_x = 0
max_y = len(lines) - 2
for y in range(len(lines)):
    if lines[y] == "":
        moves = [int(m) if m.isnumeric() else m for m in re.split(
            r'(?<=\D)|(?=\D)', lines[y+1])]
        break
    max_x = max(max_x, len(lines[y]))
    for x in range(len(lines[y])):
        if lines[y][x] != ' ':
            board[Point(x, y)] = lines[y][x]
        if start is None and lines[y][x] == '.':
            start = Point(x, y)

print("Part 1:", score(*part1(board, max_x, max_y, moves, start)))
print("Part 2:", score(*part2(board, max_x, max_y, moves, CubePoint(0, 0, 0))))
