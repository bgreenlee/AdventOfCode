import sys
import re
import math
from pprint import pp

def solve_blueprint(blueprint: tuple[int, ...]) -> int:
    costs = {
        "orebot":      { "ore": bp[0], "clay": 0,     "obsidian": 0 },
        "claybot":     { "ore": bp[1], "clay": 0,     "obsidian": 0 },
        "obsidianbot": { "ore": bp[2], "clay": bp[3], "obsidian": 0 },
        "geodebot":    { "ore": bp[4], "clay": 0,     "obsidian": bp[5] },
    }
    inventory = { "ore": 0, "clay": 0, "obsidian": 0, "geode": 0 }

    total_time = 24
    # calculate what we need to build a geode bot
    # ore: 4 ore
    # clay: 2 ore
    # obsidian: 3 ore, 14 clay
    # geode: 2 ore, 7 ob

    # ore: 2
    # obsidian: 7
        # ore: 21
        # clay: 98
            # ore: 196

    # calculate how much time it would take to build n geodebots
    # keep increasing until we exceed our time limit
    num_geodes = 0
    time = 0
    while time < total_time:
        num_geodes += 1
        ore = num_geodes * costs["geodebot"]["ore"]
        obsidian = num_geodes * costs["geodebot"]["obsidian"]
        ore += obsidian * costs["obsidianbot"]["ore"]
        clay = obsidian * costs["obsidianbot"]["clay"]
        ore += clay * costs["claybot"]["ore"]

        # print("ore:", ore)
        # print("clay:", clay)
        # print("obsidian:", obsidian)
        
        time = num_geodes + int(math.log(ore, 2)) + 1 + int(math.log(clay, 2))
        print(f"{num_geodes} geodes: time: {time}")

    return num_geodes

#
# main
#

blueprints = []
# lines = [line.rstrip() for line in sys.stdin]
lines = [
    "Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.",
    "Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian."
]
for line in lines:
    nums = [int(n) for n in re.split(r'\D+', line) if n.isnumeric()]
    blueprints.append(tuple(nums[1:]))

for bp in blueprints:
    solve_blueprint(bp)


