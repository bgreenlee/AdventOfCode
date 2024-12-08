//
//  ResonantCollinearity.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/8/24.
//

import Algorithms

typealias Point = SIMD2<Int>
extension Point {
    // greatest common divisor
    private func gcd() -> Int {
        gcd(self.x, self.y)
    }

    private func gcd(_ a: Int, _ b: Int) -> Int {
        let r = a % b
        if r != 0 {
            return gcd(b, r)
        } else {
            return b
        }
    }

    // reduce distance to its GCD (e.g. (3,3) -> (1,1))
    var normalized: Point {
        self / abs(gcd())
    }
}

class ResonantCollinearity: Solution {
    init() {
        super.init(id: 8, name: "Resonant Collinearity")
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
            }
        }
        return String(antinodes.count)
    }
}
