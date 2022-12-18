import sys
import re
import heapq
from collections import defaultdict
from dataclasses import dataclass
from typing import Self
from numpy import array, zeros, ndarray

@dataclass
class Valve:
    name: str
    rate: int
    neighbors: list[str]

    def __eq__(self, other: Self) -> bool:
        return self.name == other.name

    def __hash__(self) -> int:
        return hash(self.name)

    def __lt__(self, other: Self) -> bool:
        # this is reversed because we want to use it in a min-heap as a max-heap
        return self.rate > other.rate


def parse_input(lines: list[str]) -> dict[str, Valve]:
    valves = dict[str, Valve]()
    line_re = re.compile(r'Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.*)')
    for line in lines:
        if m := line_re.match(line):
            name, flow, neighbors = m.group(1), int(m.group(2)), m.group(3).split(", ")
            valves[name] = Valve(name, flow, neighbors)

    return valves

# Seidel's algorithm for shorted path between all pairs in a graph
# adapted from https://en.wikipedia.org/wiki/Seidel%27s_algorithm and https://stackoverflow.com/a/67438259
def all_pairs_distance(A: ndarray):
    n = len(A)
    if all(A[i, j] for i in range(n) for j in range(n) if i != j):
        return A
    Z = A @ A
    B = array([
            [1 if i != j and (A[i, j] == 1 or Z[i, j] > 0) else 0 for j in range(n)]
            for i in range(n)
        ])
    T = all_pairs_distance(B)
    X = T @ A
    degree = [sum(A[i, j] for j in range(n)) for i in range(n)]
    D = array([
            [2 * T[i, j] if X[i, j] >= T[i, j] * degree[j] else 2 * T[i, j] - 1
             for j in range(n)]
            for i in range(n)
        ])
    return D


# Dijkstra's algorithm for finding the shortest path between start and end
def find_path(valves: dict[str, Valve], start: str, end: str) -> list[str]:
    # print(f"finding path from {start} to {end}")
    visited = set[str]()
    parents = dict[str, str]()
    pqueue = list[tuple[int, str]]()
    dists = defaultdict[str, int](lambda: sys.maxsize)
    dists[start] = 0
    heapq.heappush(pqueue, (0, start))

    while pqueue:
        _, node = heapq.heappop(pqueue)
        if node == end: # we're done
            break
        visited.add(node)

        for neighbor in valves[node].neighbors:
            if neighbor in visited:
                continue
            dist = dists[node] + 1
            if dists[neighbor] > dist:
                parents[neighbor] = node
                dists[neighbor] = dist
                heapq.heappush(pqueue, (dist, neighbor))

    # return empty list if the end wasn't found
    if end not in parents:
        return []

    path: list[str] = []
    node = end
    while node != start:
        path.append(node)
        node = parents[node]
    path.reverse()
    return path



# build an adjacency matrix for the valves graph
def adj_matrix(valves: dict[str, Valve]) -> ndarray:
    keys = sorted(valves.keys())
    m = zeros((len(keys), len(keys)), dtype=int)
    for i, key in enumerate(keys):
        m[i][i] = 1
        for n in valves[key].neighbors:
            j = keys.index(n)
            m[i][j] = 1

    return m


def part1(valves: dict[str, Valve]) -> int:
    t = 0
    flow = 0
    adj = adj_matrix(valves)
    apd = all_pairs_distance(adj)
    names = sorted(valves.keys())
    opened = []
    opened_flows = []
    current = 'AA'

    def tick() -> int:
        nonlocal t, flow
        t += 1
        flow += sum(opened_flows)
        print(f"\n== Minute {t} ==")
        print(f"Valves open: {opened}, releasing {sum(opened_flows)} pressure")
        return t

    # return next best node
    def best_node(current: str) -> str:
        nodes: list[tuple[int, str]] = [] # list of (value, node name)
        unopened = [v for v in valves if valves[v].rate > 0 and v not in opened]
        for node in unopened:
            dist = apd[names.index(current), names.index(node)]
            nodes.append((valves[node].rate * (t - dist), node))
        nodes.sort()
        return nodes[-1][1]

    while tick() < 30:
        best = best_node(current)
        path = find_path(valves, current, best)
        current = path[0]
        print(f"Move to {current}")
        if tick() >= 30:
            return flow

        # turn on
        if current == best:
            print("Open valve", current)
            opened.append(current)
            opened_flows.append(valves[current].rate)

    return flow

#
# main
#

valves = dict[str, Valve]()
lines = [line.rstrip() for line in sys.stdin]
valves = parse_input(lines)

flow = part1(valves)
print("Part 1:", flow)
