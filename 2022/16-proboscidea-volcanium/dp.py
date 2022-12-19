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
    max_t = 30
    t = 0
    total_flow = 0
    open_valves = []
    open_flows = []
    names = sorted(valves.keys())
    apd = all_pairs_distance(adj_matrix(valves))

    def tick() -> int:
        nonlocal t, total_flow
        t += 1
        total_flow += sum(open_flows)
        print(f"\n== Minute {t} ==")
        print(f"Valves open: {open_valves}, releasing {sum(open_flows)} pressure")
        return t

    current = 'AA'
    tick()
    while t < max_t:
        closed_valves = [v for v in valves.keys() if valves[v].rate > 0 and v not in open_valves]
        # create our dynamic programming grid
        dp = [[(0, [])] * (max_t - t) for _ in range(len(closed_valves))] #zeros((max_t - t, len(closed_valves)), dtype=tuple[int, str])
        for i, v in enumerate(closed_valves):
            dist = apd[names.index(current), names.index(v)] # distance from our current node to the target node
            for j in range(max_t - t):
                if dist <= j+1:
                    value = valves[v].rate * (max_t - t - dist)
                    if i == 0:
                        dp[i][j] = (value, [v])
                    else:
                        if j - dist < 0 or dp[i-1][j][0] > (value + dp[i - 1][j - dist][0]):
                            dp[i][j] = (dp[i-1][j][0], [v] + dp[i-1][j][1])
                        else:
                            dp[i][j] = (value + dp[i - 1][j - dist][0], [v] + dp[i - 1][j - dist][1])  # max of previous max and value of item plus value of remaining time

        # bottom right has our destination node
        if len(dp) > 0 and len(dp[-1][-1][1]) > 0:
            dest = dp[-1][-1][1].pop()
            path = find_path(valves, current, dest)
            current = path.pop()
            tick()
            print(f"Move to valve {current}")
            if t == max_t:
                break
            if current == dest and dest not in open_valves:
                open_valves.append(dest)
                open_flows.append(valves[dest].rate)
                tick()
                print(f"Open valve {dest}")
        else:
            tick()

    return total_flow

#
# main
#

valves = dict[str, Valve]()
#lines = [line.rstrip() for line in sys.stdin]
lines = [
    "Valve AA has flow rate=0; tunnels lead to valves DD, II, BB",
    "Valve BB has flow rate=13; tunnels lead to valves CC, AA",
    "Valve CC has flow rate=2; tunnels lead to valves DD, BB",
    "Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE",
    "Valve EE has flow rate=3; tunnels lead to valves FF, DD",
    "Valve FF has flow rate=0; tunnels lead to valves EE, GG",
    "Valve GG has flow rate=0; tunnels lead to valves FF, HH",
    "Valve HH has flow rate=22; tunnel leads to valve GG",
    "Valve II has flow rate=0; tunnels lead to valves AA, JJ",
    "Valve JJ has flow rate=21; tunnel leads to valve II",
]
valves = parse_input(lines)

flow = part1(valves)
print("Part 1:", flow)

