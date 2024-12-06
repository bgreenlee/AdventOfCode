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

    struct LoopDetectedError: Error {
        let guardPos: Point
        let direction: Vec
    }

    // run through the given map, returning when the guard goes off the map
    // or throwing an exception if a loop is detected
    func runMap(_ map: [Point: Character], guardPos: Point, direction: Vec = Vec(0, -1)) throws -> [Point: Character] {
        var map = map
        var guardPos = guardPos
        var direction = direction
        var visited: [Point:Set<Vec>] = [:]

        while map[guardPos] != nil {
            map[guardPos] = "v"
            guard !visited[guardPos, default: Set()].contains(direction) else {
                throw LoopDetectedError(guardPos: guardPos, direction: direction)
            }
            visited[guardPos, default: Set()].insert(direction)
            let newPos = guardPos &+ direction
            if map[newPos] == "#" {
                direction = Vec(-direction.y, direction.x) // rotate right 90 deg
            } else {
                guardPos = newPos
            }
        }

        return map
    }

    override func part1(_ input: [String]) -> String {
        var (map, guardPos) = parseInput(input)
        do {
            map = try runMap(map, guardPos: guardPos)
        } catch {
            print("Error: \(error)") // this shouldn't happen in part 1
        }
        return String(map.values.filter { $0 == "v" }.count)
    }

    override func part2(_ input: [String]) -> String {
        var (map, guardPos) = parseInput(input)
        var possibleLoops = 0
        do {
            map = try runMap(map, guardPos: guardPos)
            let visitedPoints = map.keys.filter { map[$0] == "v" && $0 != guardPos }
            // for each of the visitedPoints, try creating an obstruction and see if a loop is detected
            for point in visitedPoints {
                var newMap = map
                newMap[point] = "#"
                do {
                    _ = try runMap(newMap, guardPos: guardPos)
                } catch {
                    possibleLoops += 1
                }
            }
        } catch {
            print("Error: \(error)") // this shouldn't happen the first time
        }
        return String(possibleLoops)
    }
}
