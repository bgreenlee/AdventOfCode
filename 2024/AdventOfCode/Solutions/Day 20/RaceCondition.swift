//
//  RaceCondition.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/20/24.
//
import Collections

class RaceCondition: Solution {
    init() {
        super.init(id: 20, name: "Race Condition", hasDisplay: true)
    }

    // parse the input, returning the set of open points and the start and end points
    func parseInput(_ input: [String]) -> (Set<Point>, Point, Point) {
        var map: Set<Point> = []
        var start = Point(0, 0)
        var end = Point(0, 0)
        for y in 0..<input.count {
            let line = Array(input[y])
            for x in 0..<line.count {
                switch line[x] {
                case ".":
                    map.insert(Point(x, y))
                case "S":
                    map.insert(Point(x, y))
                    start = Point(x, y)
                case "E":
                    map.insert(Point(x, y))
                    end = Point(x, y)
                default:
                    break
                }
            }
        }
        return (map, start, end)
    }

    // Find the racetrack path.
    // There's only one way through the maze, so it doesn't require anything fancy.
    func findPath(_ map: Set<Point>, _ start: Point, _ goal: Point) -> [Point] {
        var path: [Point] = [start]
        var currPoint: Point = start
        var prevPoint: Point = start
        while currPoint != goal {
            currPoint &+= [Vector(0, -1), Vector(1, 0), Vector(0, 1), Vector(-1, 0)]
                .first(where: { map.contains(currPoint &+ $0) && currPoint &+ $0 != prevPoint })!
            prevPoint = path.last!
            path.append(currPoint)
        }
        return path
    }

    // Manhattan distance
    func distance(_ p1: Point, _ p2: Point) -> Int {
        abs(p1.x - p2.x) + abs(p1.y - p2.y)
    }

    func countCheats(_ input: [String], maxDistance: Int, minSaved: Int) -> Int {
        let (map, start, end) = parseInput(input)
        let path = findPath(map, start, end)
        var score = 0
        for i in 0..<path.count - 4 { // 4 because that's the closest two path points can be for a shortcut to make sense
            for j in i + 4..<path.count {
                let dist = distance(path[i], path[j])
                if dist > 1 && dist <= maxDistance && dist < j - i {
                    if (j - i) - dist >= minSaved {
                        score += 1
                    }
                }
            }
        }
        return score
    }

    override func part1(_ input: [String]) -> String {
        return String(countCheats(input, maxDistance: 2, minSaved: 100))
    }

    override func part2(_ input: [String]) -> String {
        return String(countCheats(input, maxDistance: 20, minSaved: 100))
    }
}
