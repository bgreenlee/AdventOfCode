import sys
import re
import heapq
from collections import defaultdict, deque
from typing import NamedTuple
from numpy import array, zeros, ndarray


class Valve(NamedTuple):
    name: str
    rate: int
    neighbors: list[str]


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
    apd = all_pairs_distance(adj_matrix(valves))
    nodes = sorted(valves.keys())
    unopened = {name for name, valve in valves.items() if valve.rate > 0}
    time_left = 30
    paths = []
    path = []
    rate = 0
    flow = 0

    queue: deque[tuple[str, set, list, int, int, int]] = deque(
        [('AA', unopened, path, time_left, rate, flow)]
    )
    while len(queue) > 0:
        node, unopened, path, time_left, rate, flow  = queue.popleft()

        if len(unopened) == 0:
            # all done, just ride it out
            paths.append((flow, path))
            continue

        for v in unopened:
            dist = apd[nodes.index(node), nodes.index(v)]
            if dist >= time_left: # can't reach it in time
                paths.append((flow, path))
                continue
            # move to v and open it
            new_time_left = time_left - dist - 1
            new_rate = rate + valves[v].rate
            new_flow = flow + valves[v].rate * new_time_left
            queue.append((v, unopened - {v}, path + [v], new_time_left, new_rate, new_flow))

    paths.sort(reverse=True)
    print(paths[0])
    return paths[0][0]

#
# main
#

valves = dict[str, Valve]()
lines = [line.rstrip() for line in sys.stdin]
# lines = [
#     "Valve AA has flow rate=0; tunnels lead to valves DD, II, BB",
#     "Valve BB has flow rate=13; tunnels lead to valves CC, AA",
#     "Valve CC has flow rate=2; tunnels lead to valves DD, BB",
#     "Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE",
#     "Valve EE has flow rate=3; tunnels lead to valves FF, DD",
#     "Valve FF has flow rate=0; tunnels lead to valves EE, GG",
#     "Valve GG has flow rate=0; tunnels lead to valves FF, HH",
#     "Valve HH has flow rate=22; tunnel leads to valve GG",
#     "Valve II has flow rate=0; tunnels lead to valves AA, JJ",
#     "Valve JJ has flow rate=21; tunnel leads to valve II",
# ]

valves = parse_input(lines)

flow = part1(valves)
print("Part 1:", flow)

