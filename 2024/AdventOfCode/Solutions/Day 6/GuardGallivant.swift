//
//  GuardGallivant.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/6/24.
//

typealias Point = SIMD2<Int>
typealias Vec = SIMD2<Int>

class GuardGallivant: Solution {
    init() {
        super.init(id: 6, name: "Guard Gallivant")
    }

    // parse the input into a dict of Point -> Character, and
    // return a tuple of that and the position of the guard
    func parseInput(_ input: [String]) -> ([Point: Character], Point) {
        var map: [Point: Character] = [:]
        var guardPos = Point(0, 0)
        for y in 0..<input.count {
            for (x, c) in Array(input[y]).enumerated() {
                map[Point(x, y)] = c
                if c == "^" {
                    guardPos = Point(x, y)
                }
            }
        }
        return (map, guardPos)
    }

    // run through the given map, returning the updated map and whether a loop was detected
    func runMap(_ map: [Point: Character], guardPos: Point, direction: Vec = Vec(0, -1)) -> ([Point: Character], Bool) {
        var map = map
        var guardPos = guardPos
        var direction = direction
        var visited: [Point:Set<Vec>] = [:]

        while map[guardPos] != nil {
            map[guardPos] = "v"
            guard !visited[guardPos, default: Set()].contains(direction) else {
                return (map, true)
            }
            visited[guardPos, default: Set()].insert(direction)
            let newPos = guardPos &+ direction
            if map[newPos] == "#" {
                direction = Vec(-direction.y, direction.x) // rotate right 90 deg
            } else {
                guardPos = newPos
            }
        }

        return (map, false)
    }

    override func part1(_ input: [String]) -> String {
        var (map, guardPos) = parseInput(input)
        (map, _) = runMap(map, guardPos: guardPos)
        return String(map.values.filter { $0 == "v" }.count)
    }

    override func part2(_ input: [String]) -> String {
        var (map, guardPos) = parseInput(input)
        var numLoops = 0
        (map, _) = runMap(map, guardPos: guardPos) // initial run to populated visited points
        let visitedPoints = map.keys.filter { map[$0] == "v" && $0 != guardPos }
        // for each of the visitedPoints, try creating an obstruction and see if a loop is detected
        for point in visitedPoints {
            var newMap = map
            newMap[point] = "#"
            let (_, loopDetected) = runMap(newMap, guardPos: guardPos)
            if loopDetected {
                numLoops += 1
            }
        }
        return String(numLoops)
    }
}
