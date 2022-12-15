import sys
import math
import heapq
from collections import defaultdict

Point = tuple[int, int]
Grid = dict[Point, int]

# return valid neighbors for the given point
# neighbor must be adjacent (up, down, left, or right) and no more than one higher in elevation
def neighbors(p: Point, grid: Grid) -> tuple[Point, ...]:
    possible_neighbors = [
        (p[0] - 1, p[1]), (p[0], p[1] - 1),
        (p[0] + 1, p[1]), (p[0], p[1] + 1)
    ]
    valid_neighbor = lambda n: n in grid and grid[n] - grid[p] <= 1
    return tuple(filter(valid_neighbor, possible_neighbors))


# Dijkstra's algorithm for finding the shortest path between start and end
def find_path(grid: Grid, start: Point, end: Point) -> list[Point]:
    visited = set()
    parents = {}
    pqueue = []
    dists = defaultdict(lambda: math.inf)
    dists[start] = 0
    heapq.heappush(pqueue, (0, start))

    while pqueue:
        _, node = heapq.heappop(pqueue)
        if node == end: # we're done
            break
        visited.add(node)

        for neighbor in neighbors(node, grid):
            if neighbor in visited:
                continue
            dist = dists[node] + 1
            if dists[neighbor] > dist:
                parents[neighbor] = node
                dists[neighbor] = dist
                heapq.heappush(pqueue, (dist, neighbor))

    # search algorithm is done, now construct the path from the parents dict

    # return empty list if the end wasn't found
    if end not in parents:
        return []

    path: list[Point] = []
    node = end
    while node != start:
        path.append(node)
        node = parents[node]
    path.append(start)
    return path # this is reversed, but we don't care


# parse the input lines, returning the grid, start point, and end point
def parse_input(lines: list[str]) -> tuple[Grid, Point, Point]:
    grid: Grid = {}
    start: Point
    end: Point
    for y in range(len(lines)):
        for x in range(len(lines[y])):
            match lines[y][x]:
                case 'S':
                    start = (x, y)
                    grid[start] = ord('a')
                case 'E':
                    end = (x, y)
                    grid[end] = ord('z')
                case c:
                    grid[(x, y)] = ord(c)

    return grid, start, end

#
# main
#

grid, start, end = parse_input([line.rstrip() for line in sys.stdin])

# part1: find shortest path from start to end
path = find_path(grid, start, end)
print("Part 1:", len(path) - 1) # path includes start, so subtract one

# part 2: find the shortest path starting from all the lowest points
low_points = [point for point in grid if grid[point] == ord('a')]
shortest = min([len(p) for p in [find_path(grid, lp, end) for lp in low_points] if len(p) > 0])
print("Part 2:", shortest - 1)