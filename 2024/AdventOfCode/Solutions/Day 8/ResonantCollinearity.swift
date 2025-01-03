//
//  ResonantCollinearity.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/8/24.
//

import Algorithms

class ResonantCollinearity: Solution {
    init() {
        super.init(id: 8, name: "Resonant Collinearity", hasDisplay: true)
    }

    struct Map {
        var antennae: [Character: [Point]] = [:]
        var height: Int = 0
        var width: Int = 0

        init(_ input: [String]) {
            guard !input.isEmpty else { return }

            height = input.count
            width = input[0].count

            for y in 0..<height {
                for (x, c) in Array(input[y]).enumerated() {
                    if c != "." {
                        antennae[c, default: []].append(Point(x, y))
                    }
                }
            }
        }

        // return true if the given point is in the bounds of the map
        func contains(_ point: Point) -> Bool {
            point.x >= 0 && point.x < width && point.y >= 0 && point.y < height
        }
    }

//    @MainActor
//    func updateDisplay(part: SolutionPart, input: [String], antinodes: Set<Point>) {
//        // generate a string representation of the map, including antinodes
//        var display: String = ""
//        for y in 0..<input.count {
//            for x in 0..<input[0].count {
//                if antinodes.contains(Point(x, y)) {
//                    display += "#"
//                } else {
//                    let line = input[y]
//                    let charPos = line.index(line.startIndex, offsetBy: x)
//                    display += String(line[charPos])
//                }
//            }
//            display += "\n"
//        }
//        self.display[part] = display
//    }

    override func part1(_ input: [String]) -> String {
        let map = Map(input)
        var antinodes: Set<Point> = []
        for (_, points) in map.antennae {
            for pair in points.combinations(ofCount: 2) {
                let possibleAntinodes = [
                    pair[0] &- 2 &* (pair[0] &- pair[1]),
                    pair[1] &- 2 &* (pair[1] &- pair[0]),
                ]
                antinodes.formUnion(possibleAntinodes.filter { map.contains($0) })
            }
        }
        return String(antinodes.count)
    }

    override func part2(_ input: [String]) -> String {
        let map = Map(input)
        var antinodes: Set<Point> = []
        for (_, points) in map.antennae {
            for pair in points.combinations(ofCount: 2) {
                // normalize the distance between the two points, e.g. (3,3) -> (1,1)
                // note however that there are no cases in my input where this case arises
                // leaving it in though for correctness' sake
                let dist = (pair[0] &- pair[1]).normalized
                // generate antinodes up/left
                var antinode = pair[0]
                while(map.contains(antinode)) {
                    antinodes.insert(antinode)
                    antinode &-= dist
                }
                // generate antinodes down/right
                antinode = pair[0]
                while(map.contains(antinode)) {
                    antinodes.insert(antinode)
                    antinode &+= dist
                }
//                updateDisplay(part: .part2, input: input, antinodes: antinodes)
            }
        }
        return String(antinodes.count)
    }
}
