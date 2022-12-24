import sys
import re
import math
from pprint import pp

def solve_blueprint(bp: tuple[int, ...]) -> int:
    robot_cost = {
        "ore":      { "ore": bp[0], "clay": 0,     "obsidian": 0 },
        "clay":     { "ore": bp[1], "clay": 0,     "obsidian": 0 },
        "obsidian": { "ore": bp[2], "clay": bp[3], "obsidian": 0 },
        "geode":    { "ore": bp[4], "clay": 0,     "obsidian": bp[5] },
    }
    resources: dict[str, int] = { "ore": 0, "clay": 0, "obsidian": 0, "geode": 0 }
    robots: dict[str, int] = { "ore": 1, "clay": 0, "obsidian": 0, "geode": 0 }

    time_left = 24
    minute = 0
    build_robot = None # which robot to build this round
    while (minute := minute + 1) <= time_left:
        print(f"\n== Minute {minute} ==")

        # decide whether to build a robot or do nothing
        possible_robots = []
        for robot, cost in robot_cost.items():
            if all(num <= resources[resource] for resource, num in cost.items()):
                possible_robots.append(robot)
        print("Can build:", possible_robots)

        # choose the best one
        for robot in ["geode", "obsidian", "clay", "ore"]:
            if robot in possible_robots:
                build_robot = robot
                # remove the resources
                for resource, num in robot_cost[build_robot].items():
                    resources[resource] -= num
                print("Building:", robot)
                break

        # update resources
        for robot, num in robots.items():
            resources[robot] += num
            if num > 0:
                print(f"{num} {robot} robots; now have {resources[robot]} {robot}")

        # finish building the robot
        if build_robot:
            robots[build_robot] += 1
            print(f"The new {build_robot} robot is ready; you now have {robots[build_robot]} of them.")
            build_robot = None

    return resources["geode"]

#
# main
#

lines = open('test.dat').read().splitlines()
blueprints = []
for line in lines:
    nums = [int(n) for n in re.split(r'\D+', line) if n.isnumeric()]
    blueprints.append(tuple(nums[1:]))

# for bp in blueprints:
solve_blueprint(blueprints[0])


