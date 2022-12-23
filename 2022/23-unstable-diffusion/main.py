import sys
import math
from typing import NamedTuple, Self
from enum import IntEnum
from collections import defaultdict
from functools import cache


class Direction(IntEnum):
    North = 0
    South = 1
    West = 2
    East = 3

    def __add__(self, other):
        return Direction((self.value + other) % 4)

    def __sub__(self, other):
        return Direction((self.value - other) % 4)


class Point(NamedTuple):
    x: int
    y: int

    # return all points adjacent to the given one
    @cache
    def adjacent(self) -> list[Self]:
        return [self.__class__(self.x + dx, self.y + dy)
                for dx in range(-1, 2)
                for dy in range(-1, 2)
                if dx != 0 or dy != 0]

    # return the point in the given direction from this point
    @cache
    def in_direction(self, dir: Direction) -> Self:
        match dir:
            case Direction.North:
                return self.__class__(self.x, self.y - 1)
            case Direction.South:
                return self.__class__(self.x, self.y + 1)
            case Direction.West:
                return self.__class__(self.x - 1, self.y)
            case Direction.East:
                return self.__class__(self.x + 1, self.y)


class ElfMap:
    elves: set[Point]

    def __init__(self, lines: list[str]):
        self.elves = set(Point(x, y) for y in range(len(lines))
                         for x in range(len(lines[y])) if lines[y][x] == '#')

    # display the map
    def __str__(self):
        output = ''
        min_x, max_x, min_y, max_y = self.bounds()
        for y in range(min_y, max_y + 1):
            for x in range(min_x, max_x + 1):
                output += '#' if Point(x, y) in self.elves else '.'
            output += "\n"
        return output

    # return populated adjacent points
    def neighbors(self, p: Point) -> list[Point]:
        return [a for a in p.adjacent() if a in self.elves]

    # return true if the elf at the give point can move in the given direction
    def can_move(self, p: Point, dir: Direction) -> bool:
        neighbors = self.neighbors(p)
        match dir:
            case Direction.North:
                return not any(p in neighbors for p in [Point(p.x - 1, p.y - 1), Point(p.x, p.y - 1), Point(p.x + 1, p.y - 1)])
            case Direction.South:
                return not any(p in neighbors for p in [Point(p.x - 1, p.y + 1), Point(p.x, p.y + 1), Point(p.x + 1, p.y + 1)])
            case Direction.West:
                return not any(p in neighbors for p in [Point(p.x - 1, p.y - 1), Point(p.x - 1, p.y), Point(p.x - 1, p.y + 1)])
            case Direction.East:
                return not any(p in neighbors for p in [Point(p.x + 1, p.y - 1), Point(p.x + 1, p.y), Point(p.x + 1, p.y + 1)])

        return False

    # move an elf from src to dest
    def move(self, src: Point, dest: Point):
        self.elves.remove(src)
        self.elves.add(dest)

    # return the map bounding box
    def bounds(self) -> tuple[int, int, int, int]:
        min_x, max_x = math.inf, 0
        min_y, max_y = math.inf, 0
        for elf in self.elves:
            min_x, max_x = min(min_x, elf.x), max(max_x, elf.x)
            min_y, max_y = min(min_y, elf.y), max(max_y, elf.y)

        return min_x, max_x, min_y, max_y

    # return the number of empty tiles in the elf map
    def empty_tiles_count(self) -> int:
        min_x, max_x, min_y, max_y = self.bounds()
        return (max_x - min_x + 1) * (max_y - min_y + 1) - len(self.elves)

    # do a round of moves, return the number of moves made
    def do_round(self, start_dir=Direction.North) -> int:
        proposed_move = dict[Point, Point]()
        proposed_move_count = defaultdict[Point, int](int)
        total_move_count = 0

        # sub-round 1: proposals
        for elf in self.elves:
            neighbors = self.neighbors(elf)
            if len(neighbors) == 0:
                continue  # no neighbors, do nothing
            for dir in [Direction(d % 4) for d in range(start_dir.value, start_dir.value + 4)]:
                if self.can_move(elf, dir):
                    dest = elf.in_direction(dir)
                    proposed_move[elf] = dest
                    proposed_move_count[dest] += 1
                    break

        # sub-round 2: moves
        for src, dest in proposed_move.items():
            if proposed_move_count[dest] == 1:
                # only one to propose moving there, so move the elf
                self.move(src, dest)
                total_move_count += 1

        return total_move_count


def part1(elf_map: ElfMap) -> int:
    start_dir = Direction.North

    for _ in range(10):
        elf_map.do_round(start_dir)
        start_dir += 1

    return elf_map.empty_tiles_count()


def part2(elf_map: ElfMap) -> int:
    start_dir = Direction.North

    rounds = 1
    while elf_map.do_round(start_dir) != 0:
        start_dir += 1
        rounds += 1

    return rounds


#
# main
#
lines = sys.stdin.read().splitlines()
print("Part 1:", part1(ElfMap(lines)))
print("Part 2:", part2(ElfMap(lines)))
