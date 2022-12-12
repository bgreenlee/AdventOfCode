import sys
import math
import heapq
from dataclasses import dataclass
from collections import defaultdict


@dataclass(frozen=True)
class Point:
    x: int
    y: int

    # need to define this for the priority queue
    # it doesn't matter if it is meaningful
    def __lt__(self, other):
        return self.x < other.x if self.y == other.y else self.y < other.y

Grid = dict[Point, int]

def neighbors(p: Point, grid: Grid) -> list[Point]:
    possible_neighbors = [
        Point(p.x - 1, p.y), Point(p.x, p.y - 1),
        Point(p.x + 1, p.y), Point(p.x, p.y + 1)
    ]
    valid_neighbor = lambda n: n in grid and grid[n] - grid[p] <= 1
    return filter(valid_neighbor, possible_neighbors)


def find_path(grid: Grid, start: Point, end: Point) -> list[Point]:
    parentsMap, _ = dijkstra(grid, start, end)
    # construct path
    path: list[Point] = []
    if end not in parentsMap:
        return path

    node = end
    while node != start:
        path.append(node)
        if node not in parentsMap:
            print(parentsMap)
        node = parentsMap[node]
    path.append(start)
    return path


def dijkstra(grid: Grid, start: Point, end: Point) -> tuple[dict, dict]:
    visited = set()
    parentsMap = {}
    pqueue = []
    nodeCosts = defaultdict(lambda: math.inf)
    nodeCosts[start] = 0
    heapq.heappush(pqueue, (0, start))

    while pqueue:
        _, node = heapq.heappop(pqueue)
        visited.add(node)

        for neighbor in neighbors(node, grid):
            if neighbor in visited:
                continue
            
            newCost = nodeCosts[node] + 1
            if nodeCosts[neighbor] > newCost:
                parentsMap[neighbor] = node
                nodeCosts[neighbor] = newCost
                if neighbor == end: # we're done
                    return parentsMap, nodeCosts
                heapq.heappush(pqueue, (newCost, neighbor))

    return parentsMap, nodeCosts    

#
# main
#

grid: Grid = {}
start: Point
end: Point
lines = [line.rstrip() for line in sys.stdin]
for y in range(len(lines)):
    for x in range(len(lines[y])):
        match lines[y][x]:
            case 'S':
                start = Point(x, y)
                grid[start] = ord('a')
            case 'E':
                end = Point(x, y)
                grid[end] = ord('z')
            case c:
                grid[Point(x, y)] = ord(c)

path = find_path(grid, start, end)
print("Part 1:", len(path) - 1) # path includes start, so subtract one

# find paths for all lowest points
low_points = [point for point in grid if grid[point] == ord('a')]
# find the shortest, ignoring any empty paths (since that indicates it couldn't get from start to end)
shortest = min([len(p) for p in [find_path(grid, lp, end) for lp in low_points] if len(p) > 0])
print("Part 2:", shortest - 1)