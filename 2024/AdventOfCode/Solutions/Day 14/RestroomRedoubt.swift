//
//  RestroomRedoubt.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/14/24.
//

class RestroomRedoubt: Solution {
    init() {
        super.init(id: 14, name: "Restroom Redoubt")
    }

    struct Robot {
        var pos: Point
        let vec: Vector
    }

    func parseInput(_ input: [String]) -> [Robot] {
        var robots: [Robot] = []
        for line in input {
            if let m = line.wholeMatch(of: /p=(\d+),(\d+) v=([-\d]+),([-\d]+)/) {
                robots.append(
                    Robot(pos: Point(Int(m.1)!, Int(m.2)!), vec: Vector(Int(m.3)!, Int(m.4)!))
                )
            }
        }
        return robots
    }

    func cycleRobots(_ robots: inout [Robot], width: Int, height: Int) {
        for i in robots.indices {
            robots[i].pos &+= robots[i].vec &+ Point(width, height)
            robots[i].pos %= Point(width, height)
        }
    }

    func display(_ robots: [Robot], width: Int, height: Int) {
        for y in 0..<height {
            for x in 0..<width {
                if robots.contains(where: { $0.pos == Point(x, y) }) {
                    print("#", terminator: "")
                } else {
                    print(".", terminator: "")
                }
            }
            print()
        }
    }

    override func part1(_ input: [String]) -> String {
        var robots = parseInput(input)
        let width = robots.max(by: { $0.pos.x < $1.pos.x })!.pos.x + 1  // making assumptions here, but it works
        let height = robots.max(by: { $0.pos.y < $1.pos.y })!.pos.y + 1

        for _ in 1...100 {
            cycleRobots(&robots, width: width, height: height)
        }

        let q1 = robots.filter { $0.pos.x < width / 2 && $0.pos.y < height / 2 }.count
        let q2 = robots.filter { $0.pos.x > width / 2 && $0.pos.y < height / 2 }.count
        let q3 = robots.filter { $0.pos.x < width / 2 && $0.pos.y > height / 2 }.count
        let q4 = robots.filter { $0.pos.x > width / 2 && $0.pos.y > height / 2 }.count

        return String(q1 * q2 * q3 * q4)
    }

    override func part2(_ input: [String]) -> String {
        var robots = parseInput(input)
        let width = robots.max(by: { $0.pos.x < $1.pos.x })!.pos.x + 1  // making assumptions here, but it works
        let height = robots.max(by: { $0.pos.y < $1.pos.y })!.pos.y + 1

        // cycle until we find an arrangement with a lot of robots with the same x & y positions
        var cycles: Int = 0
        while true {
            cycleRobots(&robots, width: width, height: height)
            cycles += 1
            if robots.grouped(by: { $0.pos.x }).values.contains(where: { $0.count > 20 })
                && robots.grouped(by: { $0.pos.y }).values.contains(where: { $0.count > 20 })
            {
                break
            }
        }

        display(robots, width: width, height: height)

        return String(cycles)
    }
}
