//
//  HoofIt.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/10/24.
//

class HoofIt: Solution {
    init() {
        super.init(id: 10, name: "Hoof It")
    }

    let cardinalDirections = [Vector(0, -1), Vector(1, 0), Vector(0, 1), Vector(-1, 0)]

    func parseInput(_ input: [String]) -> ([Point: Int], [Point]) {
        var map: [Point: Int] = [:]
        var trailheads: [Point] = []
        for y in 0..<input.count {
            for (x, c) in Array(input[y]).enumerated() {
                map[Point(x, y)] = c.wholeNumberValue
                if c == "0" {
                    trailheads.append(Point(x, y))
                }
            }
        }
        return (map, trailheads)
    }

    // find distinct peaks
    func findPeaks(_ map: [Point: Int], _ point: Point, _ peaks: inout Set<Point>) {
        if map[point] == 9 {
            peaks.insert(point)
            return
        }
        for dir in cardinalDirections {
            if let nextPointValue = map[point &+ dir] {
                if nextPointValue == map[point]! + 1 {
                    findPeaks(map, point &+ dir, &peaks)
                }
            }
        }
    }

    // count the number of distinct peaks reachable from the trailhead
    func countPeaks(_ map: [Point: Int], _ trailhead: Point) -> Int {
        var peaks: Set<Point> = []
        findPeaks(map, trailhead, &peaks)
        return peaks.count
    }

    // count all paths from the point to a peak
    func countAllPaths(_ map: [Point: Int], _ point: Point, _ score: Int = 0) -> Int {
        if map[point] == 9 {
            return score + 1
        }
        var score = score
        for dir in cardinalDirections {
            if let nextPointValue = map[point &+ dir] {
                if nextPointValue == map[point]! + 1 {
                    score = countAllPaths(map, point &+ dir, score)
                }
            }
        }
        return score
    }

    override func part1(_ input: [String]) -> String {
        let (map, trailheads) = parseInput(input)
        let score = trailheads.reduce(0) { (acc, trailhead) in acc + countPeaks(map, trailhead) }
        return String(score)
    }

    override func part2(_ input: [String]) -> String {
        let (map, trailheads) = parseInput(input)
        let rating = trailheads.reduce(0) { (acc, trailhead) in acc + countAllPaths(map, trailhead) }
        return String(rating)
    }
}
