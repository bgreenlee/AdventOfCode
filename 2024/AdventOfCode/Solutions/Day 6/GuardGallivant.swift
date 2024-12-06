//
//  GuardGallivant.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/6/24.
//

typealias Point = SIMD2<Int>
typealias Direction = SIMD2<Int>

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

    // run through the given map, returning the list of visited points and whether a loop was detected
    func runMap(_ map: [Point: Character], guardPos: Point, dir: Direction = Direction(0, -1))
        -> ([Point], Bool)
    {
        var guardPos = guardPos
        var dir = dir
        var visited: [Point: [Direction]] = [:]

        while map[guardPos] != nil {
            if visited[guardPos, default: []].contains(dir) {
                return (Array(visited.keys), true)  // found a loop
            }
            visited[guardPos, default: []].append(dir)
            let newPos = guardPos &+ dir
            if map[newPos] == "#" {
                dir = Direction(-dir.y, dir.x)  // rotate right 90 deg
            } else {
                guardPos = newPos
            }
        }

        return (Array(visited.keys), false)
    }

    override func part1(_ input: [String]) -> String {
        let (map, guardPos) = parseInput(input)
        let (visitedPoints, _) = runMap(map, guardPos: guardPos)

        return String(visitedPoints.count)
    }

    override func part2(_ input: [String]) -> String {
        let (map, guardPos) = parseInput(input)
        let (visitedPoints, _) = runMap(map, guardPos: guardPos)  // initial run to populate visited points

        // for each of the visitedPoints, try creating an obstruction and see if a loop is detected
        var numLoops = 0
        for point in visitedPoints.filter({ $0 != guardPos }) {
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
