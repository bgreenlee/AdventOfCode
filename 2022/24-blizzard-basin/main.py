import sys
import heapq
from collections import defaultdict
from typing import NamedTuple, Self


class Point(NamedTuple):
    x: int
    y: int


class Point3D(NamedTuple):
    x: int
    y: int
    z: int

    # return all points adjacent to the given one
    # we can't move diagonally on the x,y axis, but we can along the z
    # we also always have to go forward in time (z)
    def adjacent(self) -> list[Self]:
        return [self.__class__(self.x + dx, self.y + dy, self.z + dz)
                for dx, dy, dz in [(0, 0, 1), (1, 0, 1), (-1, 0, 1),  (0, 1, 1), (0, -1, 1)]]


class Valley:
    open_space: set[Point3D]
    blizzards: defaultdict[Point, list[str]]
    time: int
    max_x: int
    max_y: int
    start: Point3D
    end: Point
    # blizzard directions to x,y offsets
    dir_map = {'>': (1, 0), 'v': (0, 1), '<': (-1, 0), '^': (0, -1)}

    def __init__(self, lines):
        self.time = 0
        # set valley bounds, excluding entry/exit points
        self.max_x = len(lines[0]) - 2
        self.max_y = len(lines) - 2
        self.start = Point3D(1, 0, 0)
        self.end = Point(self.max_x, self.max_y + 1)
        self.open_space = set()
        self.blizzards = defaultdict(list)

        for y in range(len(lines)):
            for x in range(len(lines[y])):
                match lines[y][x]:
                    case '.':
                        self.open_space.add(Point3D(x, y, 0))
                    case ('>' | 'v' | '<' | '^') as dir:
                        self.blizzards[Point(x, y)].append(dir)


    def __str__(self) -> str:
        output = f"Minute {self.time}\n"
        for y in range(self.max_y + 2):
            for x in range(self.max_x + 2):
                p3 = Point3D(x, y, self.time)
                p = Point(x, y)
                if p3 in self.open_space:
                    output += '.'
                elif p in self.blizzards:
                    output += self.blizzards[p][0] if len(self.blizzards[p]) == 1 else str(len(self.blizzards[p]))
                else:
                    output += '#'
            output += "\n"

        return output

    # move n minutes forward: move the blizzards and extend the 3D map
    def tick(self, n = 1):
        for _ in range(n):
            self.time += 1

            # advance the blizzards
            new_blizzards = defaultdict[Point, list[str]](list)
            for blizzard, dirs in self.blizzards.items():
                for dir in dirs:
                    dx, dy = self.dir_map[dir]
                    new_blizzards[Point((blizzard.x + dx - 1) % self.max_x + 1,
                                        (blizzard.y + dy - 1) % self.max_y + 1)].append(dir)
            self.blizzards = new_blizzards

            # update the 3D map
            for y in range(1, self.max_y + 1):
                for x in range(1, self.max_x + 1):
                    if not Point(x, y) in self.blizzards:
                        self.open_space.add(Point3D(x, y, self.time))
            # make sure entrance and exit are always there
            self.open_space.add(Point3D(self.start.x, self.start.y, self.time))
            self.open_space.add(Point3D(self.end.x, self.end.y, self.time))


    # return open neighbors of the given point
    def neighbors(self, point: Point3D):
        return [p for p in point.adjacent() if p in self.open_space]

    # Dijkstra's algorithm for finding the shortest path between start and end
    # return the end point if successful
    def find_path(self, start: Point3D, end: Point) -> Point3D | None:
        visited = set[Point3D]()
        parents = dict[Point3D, Point3D]()
        pqueue = list[tuple[int, Point3D]]()
        dists = defaultdict(lambda: sys.maxsize)
        dists[start] = 0
        heapq.heappush(pqueue, (0, start))

        while pqueue:
            _, node = heapq.heappop(pqueue)
            if node.x == end.x and node.y == end.y:  # we're done
                return node
            visited.add(node)

            for neighbor in self.neighbors(node):
                if neighbor in visited:
                    continue
                dist = dists[node] + 1
                if dist < dists[neighbor]:
                    parents[neighbor] = node
                    dists[neighbor] = dist
                    heapq.heappush(pqueue, (dist, neighbor))

        return None

#
# main
#
lines = sys.stdin.read().splitlines()
valley = Valley(lines)
valley.tick(100)
while not (exit := valley.find_path(valley.start, valley.end)):
    valley.tick(100)
print("Part 1:", exit.z)

# go back to start
start, end = exit, Point(valley.start.x, valley.start.y)
while not (exit := valley.find_path(start, end)):
    valley.tick(100)

# and back to end
start, end = exit, valley.end
while not (exit := valley.find_path(start, end)):
    valley.tick(100)
print("Part 2:", exit.z)
