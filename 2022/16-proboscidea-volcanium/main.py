import sys
import re
from collections import deque
from typing import NamedTuple
from numpy import array, zeros, ndarray
from itertools import combinations
from functools import cache

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


@cache
def distance(a: str, b: str) -> int:
    return apd[nodes.index(a), nodes.index(b)]


def max_flow(unopened: set[str], time_left: int) -> int:
    max_flows = []
    rate = 0
    flow = 0

    queue: deque[tuple[str, set, int, int, int]] = deque(
        [('AA', unopened, time_left, rate, flow)]
    )
    while len(queue) > 0:
        node, unopened, time_left, rate, flow  = queue.popleft()

        if len(unopened) == 0: # all done, just ride it out
            max_flows.append(flow)
            continue

        for v in unopened:
            dist = distance(node, v)
            if dist >= time_left: # can't reach it in time
                max_flows.append(flow)
                continue
            # move to v and open it
            new_time_left = time_left - dist - 1
            vrate = valves[v].rate
            queue.append((v, unopened - {v}, new_time_left, rate + vrate, flow + vrate * new_time_left))

    return max(max_flows)


def part1() -> int:
    unopened = {name for name, valve in valves.items() if valve.rate > 0}
    return max_flow(unopened, 30)

def part2() -> int:
    unopened = {name for name, valve in valves.items() if valve.rate > 0}
    max_max_flow = 0

    # partition unopened
    for combo in combinations(unopened, int(len(unopened)/2)):
        f1 = max_flow(set(combo), 26)
        f2 = max_flow(unopened - set(combo), 26)
        max_max_flow = max(max_max_flow, f1 + f2)

    return max_max_flow

#
# main
#

lines = [line.rstrip() for line in sys.stdin]

global valves, apd, nodes
valves = parse_input(lines)
apd = all_pairs_distance(adj_matrix(valves))
print(adj_matrix(valves))
print(apd)
nodes = sorted(valves.keys())

print("Part 1:", part1())
print("Part 2:", part2())
