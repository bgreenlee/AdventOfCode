import Accelerate.vecLib.LinearAlgebra
//
//  ClawContraption.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/13/24.
//
import Numerics

class ClawContraption: Solution {
    init() {
        super.init(id: 13, name: "Claw Contraption", hasDisplay: false)
    }

    func parseInput(_ input: [String]) -> [(Int, Int, Int, Int, Int, Int)] {
        let matches =
            input
            .joined()
            .matches(
                of:
                    #/
                        Button\s+A:\s+X\+(\d+),\s+Y\+(\d+).*?
                        Button\s+B:\s+X\+(\d+),\s+Y\+(\d+).*?
                        Prize:\s+X=(\d+),\s+Y=(\d+)
                    /#
            )
        return matches.map {
            (Int($0.1)!, Int($0.2)!, Int($0.3)!, Int($0.4)!, Int($0.5)!, Int($0.6)!)
        }
    }

    func solve(_ input: [String], max: Double = 0, add: Int = 0) -> Int {
        let configurations = parseInput(input)
        var total: Int = 0
        for (ax, ay, bx, by, px, py) in configurations {
            let (px, py) = (add + px, add + py)
            let b = Double(ay * px - ax * py) / Double(ay * bx - ax * by)
            let a = Double(Double(px) - b * Double(bx)) / Double(ax)
            if a < 0 || b < 0 || (max > 0 && (a > max || b > max))
                || !a.isApproximatelyEqual(to: a.rounded(), absoluteTolerance: 0.001)
                || !b.isApproximatelyEqual(to: b.rounded(), absoluteTolerance: 0.001)
            {
                continue  // not a valid solution
            }
            total += 3 * Int(a) + Int(b)
        }
        return total
    }

    override func part1(_ input: [String]) -> String {
        return String(solve(input, max: 100))
    }

    override func part2(_ input: [String]) -> String {
        return String(solve(input, add: 10_000_000_000_000))
    }
}
