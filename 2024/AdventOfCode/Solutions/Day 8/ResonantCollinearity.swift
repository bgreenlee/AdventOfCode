//
//  ResonantCollinearity.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/8/24.
//

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
        self / gcd()
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
            for i in 0..<points.count - 1 {
                for j in i + 1..<points.count {
                    let possibleAntinodes = [
                        points[i] &- 2 &* (points[i] &- points[j]),
                        points[j] &- 2 &* (points[j] &- points[i]),
                    ]
                    antinodes.formUnion(possibleAntinodes.filter { map.contains($0) })
                }
            }
        }
        return String(antinodes.count)
    }

    override func part2(_ input: [String]) -> String {
        let map = Map(input)
        var antinodes: Set<Point> = []
        for (_, points) in map.antennae {
            for i in 0..<points.count - 1 {
                for j in i + 1..<points.count {
                    let dist = (points[i] &- points[j]).normalized
                    // generate antinodes up/left
                    var antinode = points[i]
                    while(map.contains(antinode)) {
                        antinodes.insert(antinode)
                        antinode &-= dist
                    }
                    // generate aninodes down/right
                    antinode = points[i]
                    while(map.contains(antinode)) {
                        antinodes.insert(antinode)
                        antinode &+= dist
                    }
                }
            }
        }
        return String(antinodes.count)
    }
}
