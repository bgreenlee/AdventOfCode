//
//  CeresSearch.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/4/24.
//

typealias point = SIMD2<Int>
typealias vec = SIMD2<Int>  // pendantry

struct Grid: Sequence {
    private var grid: [point: Character] = [:]

    init(_ rows: [String]) {
        for y in 0..<rows.count {
            let chars = Array(rows[y])
            for x in 0..<chars.count {
                grid[point(x, y)] = chars[x]
            }
        }
    }

    // proxy our iterator to the grid
    func makeIterator() -> Dictionary<point, Character>.Iterator {
        grid.makeIterator()
    }

    // get the character at a given point
    // return a space if the point is not in the grid
    func at(_ p: point) -> Character {
        grid[p] ?? " "
    }

    // get all words in each of the cardinal directions
    func words(at p: point, length: Int = 4) -> [String] {
        [
            vec(0, -1), vec(1, -1), vec(1, 0), vec(1, 1),
            vec(0, 1), vec(-1, 1), vec(-1, 0), vec(-1, -1),
        ].map { v in
            String(
                (0..<length).map {
                    at(point(p.x, p.y) &+ v &* $0)
                }
            )
        }
    }

    // get the two 3-letter words that make up the X
    func xwords(at p: point) -> [String] {
        [
            String([
                at(point(p.x - 1, p.y + 1)), at(point(p.x, p.y)), at(point(p.x + 1, p.y - 1)),
            ]),
            String([
                at(point(p.x - 1, p.y - 1)), at(point(p.x, p.y)), at(point(p.x + 1, p.y + 1)),
            ]),
        ]
    }
}

class CeresSearch: Solution {
    init() {
        super.init(id: 4, name: "Ceres Search")
    }

    override func part1() -> String {
        let grid = Grid(input)
        var count = 0
        for (p, c) in grid {
            if c == "X" {
                count += grid.words(at: p).filter { $0 == "XMAS" }.count
            }
        }
        return String(count)
    }

    override func part2() -> String {
        let grid = Grid(input)
        var count = 0
        for (p, c) in grid {
            if c == "A" {
                if grid.xwords(at: p).allSatisfy({ $0 == "MAS" || $0 == "SAM" }) {
                    count += 1
                }
            }
        }
        return String(count)
    }
}
