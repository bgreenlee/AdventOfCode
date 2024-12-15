//
//  RestroomRedoubt.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/14/24.
//

class RestroomRedoubt: Solution {
    init() {
        super.init(id: 14, name: "Restroom Redoubt", hasDisplay: true)
    }

    struct Robot {
        var pos: Point
        let vec: Vector
    }

    // parse input into list of robots and width and height
    // this assumes there will be at least one robot at the edges of the map,
    // which is the case for my input at least
    func parseInput(_ input: [String]) -> ([Robot], Int, Int) {
        var robots: [Robot] = []
        var (maxX, maxY) = (0, 0)
        for line in input {
            if let m = line.wholeMatch(of: /p=(\d+),(\d+) v=([-\d]+),([-\d]+)/) {
                let (x, y) = (Int(m.1)!, Int(m.2)!)
                (maxX, maxY) = (max(maxX, x), max(maxY, y))
                robots.append(
                    Robot(pos: Point(x, y), vec: Vector(Int(m.3)!, Int(m.4)!))
                )
            }
        }
        return (robots, maxX + 1, maxY + 1)
    }

    func cycleRobots(_ robots: inout [Robot], width: Int, height: Int) {
        for i in robots.indices {
            robots[i].pos &+= robots[i].vec &+ Point(width, height)
            robots[i].pos %= Point(width, height)
        }
    }

    func generateDisplay(_ robots: [Robot], width: Int, height: Int) -> String {
        var display: [Character] = Array(repeating: ".", count: (width + 1) * height)
        for y in 0..<height {
            for x in 0..<width {
                if robots.contains(where: { $0.pos == Point(x, y) }) {
                    display[y * (width + 1) + x] = "#"
                }
            }
            display[y * (width + 1) + width] = "\n"
        }
        return String(display)
    }

    override func part1(_ input: [String]) -> String {
        var (robots, width, height) = parseInput(input)

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
        var (robots, width, height) = parseInput(input)

        // cycle until we find an arrangement with a lot of robots with the same x & y positions
        var cycles: Int = 0
        while true {
            cycleRobots(&robots, width: width, height: height)
            addFrame(part: .part2, generateDisplay(robots, width: width, height: height))
            cycles += 1
            if robots.grouped(by: { $0.pos.x }).values.contains(where: { $0.count > 20 })
                && robots.grouped(by: { $0.pos.y }).values.contains(where: { $0.count > 20 })
            {
                break
            }
        }

        print(frames[.part2]?.last ?? "")

        return String(cycles)
    }
}
