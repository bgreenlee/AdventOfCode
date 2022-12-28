import sys
import re
import math

# I couldn't get my version working, so I borrowed heavily from
# https://github.com/betaveros/advent-of-code-2022/blob/main/p19.noul
# in order to move on with my life.

ORE, CLAY, OBSIDIAN, GEODE = range(4)

# DFS with a lot of optimizations
def solve_blueprint(bp: tuple[int, ...], time_left: int) -> int:
    robot_cost = [
        (bp[0], 0, 0, 0), # orebot: ore, clay, obsidian, geode
        (bp[1], 0, 0, 0), # claybot
        (bp[2], bp[3], 0, 0), # obsidianbot
        (bp[4], 0, bp[5], 0), # geodebot
    ]
    resources: tuple[int,...] = (0, 0, 0, 0) # ore, clay, obsidian, geode
    robots: tuple[int,...] = (1, 0, 0, 0) # ore, clay, obsidian, geode
    max_ore_cost = max(cost[ORE] for cost in robot_cost) # most ore we need to build anything
    best = 0 # our best geode score

    stack: list[tuple[tuple[int,...], tuple[int,...], int]] = [(resources, robots, time_left)]
    while stack:
        resources, robots, time_left = stack.pop()

        best_idle = resources[GEODE] + robots[GEODE] * time_left # how many geodes we'd have if we did nothing else
        if best_idle > best:
            best = best_idle

        best_max = best_idle + time_left * (time_left - 1) // 2 # most we could expect to get if we produced a geode bot every minute from here on out
        if best_max <= best:
            continue # can't beat the current best, so bail on this path

        for robot, cost in enumerate(robot_cost):
            if robot == ORE and robots[ORE] >= max_ore_cost:
                continue # we have enough ore
            if robot == CLAY and robots[CLAY] >= robot_cost[OBSIDIAN][CLAY]:
                continue # we have enough clay
            if robot == OBSIDIAN and robots[OBSIDIAN] >= robot_cost[GEODE][OBSIDIAN]:
                continue # we have enough obsidian

            # calculate how many minutes we can jump forward
            minutes: list[int] = []
            for num_resource, num_robots, resource_cost in zip(resources, robots, cost):
                if num_resource >= resource_cost:
                    minutes.append(0) # we have enough to build a new robot
                elif num_robots > 0:
                    minutes.append((resource_cost - num_resource + num_robots - 1) // num_robots) # wait until we have enough
                else:
                    minutes.append(999) # no robot of this type and not enough resources
            min_to_jump = max(minutes)

            if min_to_jump < 999 and min_to_jump < time_left:
                new_resources = [resources[i] + (min_to_jump + 1) * robots[i] - cost[i] for i in range(4)]
                new_robots = [n + 1 if i == robot else n for i, n in enumerate(robots)] # build robot
                stack.append((tuple(new_resources), tuple(new_robots), time_left - min_to_jump - 1))

    return best

#
# main
#
if __name__ == "__main__":
    lines = sys.stdin.read().splitlines()
    blueprints = []
    for line in lines:
        nums = [int(n) for n in re.split(r'\D+', line) if n.isnumeric()]
        blueprints.append(tuple(nums[1:]))

    # part 1
    results = [solve_blueprint(bp, 24) for bp in blueprints]
    quality_levels = [result * (i+1) for i, result in enumerate(results)]
    print("Part 1:", sum(quality_levels))

    # part 2
    results = [solve_blueprint(bp, 32) for bp in blueprints[:3]]
    print("Part 2:", math.prod(results))



