//
//  GuardGallivant.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/6/24.
//
import Dispatch

class GuardGallivant: Solution {
    init() {
        super.init(id: 6, name: "Guard Gallivant")
    }

    typealias Point = SIMD2<Int>
    typealias Direction = SIMD2<Int>

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
    func runMap(_ map: [Point: Character], guardPos: Point, dir: Direction = Direction(0, -1), newObstacle: Point? = nil)
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
            if newPos == newObstacle || map[newPos] == "#" {
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

    func parallelLoopDetection(map: [Point: Character], guardPos: Point, visitedPoints: [Point]) -> Int {
        let counterQueue = DispatchQueue(label: "counterQueue")
        var numLoops = 0

        let group = DispatchGroup()

        let pointsToCheck = visitedPoints.filter { $0 != guardPos }
        DispatchQueue.concurrentPerform(iterations: pointsToCheck.count) { index in
            let point = pointsToCheck[index]
            let (_, loopDetected) = runMap(map, guardPos: guardPos, newObstacle: point)
            if loopDetected {
                group.enter()
                counterQueue.async {
                    numLoops += 1
                    group.leave()
                }
            }
        }

        group.wait()

        return numLoops
    }

    override func part2(_ input: [String]) -> String {
        let (map, guardPos) = parseInput(input)
        let (visitedPoints, _) = runMap(map, guardPos: guardPos)  // initial run to populate visited points

        let numLoops = parallelLoopDetection(map: map, guardPos: guardPos, visitedPoints: visitedPoints)

        return String(numLoops)
    }
}
