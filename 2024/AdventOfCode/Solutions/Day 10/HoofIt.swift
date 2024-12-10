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

    // parse the input, returning a map of Point -> Int and an array of trailhead positions
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

    // find distinct peaks and count the number of paths to get there
    func findPeaksAndPaths(_ map: [Point: Int], _ point: Point, _ peaks: inout Set<Point>, _ numPaths: Int = 0) -> Int{
        if map[point] == 9 {
            peaks.insert(point)
            return numPaths + 1
        }
        var numPaths = numPaths
        for dir in cardinalDirections {
            if let nextPointValue = map[point &+ dir] {
                if nextPointValue == map[point]! + 1 {
                    numPaths = findPeaksAndPaths(map, point &+ dir, &peaks, numPaths)
                }
            }
        }
        return numPaths
    }

    // count the number of distinct peaks reachable from the trailhead
    func countPeaksAndPaths(_ map: [Point: Int], _ trailhead: Point) -> (Int, Int) {
        var peaks: Set<Point> = []
        let numPaths = findPeaksAndPaths(map, trailhead, &peaks)
        return (peaks.count, numPaths)
    }

    override func part1(_ input: [String]) -> String {
        let (map, trailheads) = parseInput(input)
        let score = trailheads.reduce(0) { (acc, trailhead) in
            let (numPeaks, _) = countPeaksAndPaths(map, trailhead)
            return acc + numPeaks
        }
        return String(score)
    }

    override func part2(_ input: [String]) -> String {
        let (map, trailheads) = parseInput(input)
        let rating = trailheads.reduce(0) { (acc, trailhead) in
            let (_, numPaths) = countPeaksAndPaths(map, trailhead)
            return acc + numPaths
        }
        return String(rating)
    }
}
