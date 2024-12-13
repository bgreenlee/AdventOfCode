import Accelerate.vecLib.LinearAlgebra
//
//  ClawContraption.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/13/24.
//
import Foundation
import Numerics

class ClawContraption: Solution {
    init() {
        super.init(id: 13, name: "Claw Contraption", hasDisplay: false)
    }

    func parseInput(_ input: [String]) -> [(Vector, Vector, Point)] {
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
            (
                Vector(Int($0.1)!, Int($0.2)!),
                Vector(Int($0.3)!, Int($0.4)!),
                Point(Int($0.5)!, Int($0.6)!)
            )
        }
    }

    // from https://developer.apple.com/documentation/accelerate/solving_systems_of_linear_equations_with_lapack
    func solveSystemOfEquations(a: [Double], b: [Double]) -> [Double]? {
        let dimension = b.count // technically: Int(sqrt(Double(a.count)))
        let rightHandSideCount = 1
        var info: __LAPACK_int = 0

        /// Create a mutable copy of the right hand side matrix _b_ that the function returns as the solution matrix _x_.
        var x = b

        /// Create a mutable copy of `a` to pass to the LAPACK routine. The routine overwrites `mutableA`
        /// with the factors `L` and `U` from the factorization `A = P * L * U`.
        var mutableA = a

        var ipiv = [__LAPACK_int](repeating: 0, count: dimension)

        /// Call `dgesv_` to compute the solution.
        withUnsafePointer(to: __LAPACK_int(dimension)) { n in
            withUnsafePointer(to: __LAPACK_int(rightHandSideCount)) { nrhs in
                dgesv_(n, nrhs, &mutableA, n, &ipiv, &x, n, &info)
            }
        }

        if info != 0 {
            print("solveSystemOfEquations error \(info)")
            return nil
        }
        return x
    }

    func solve(_ input: [String], add: Int = 0) -> Int {
        let configurations = parseInput(input)
        var total: Int = 0
        for conf in configurations {
            let matA: [Double] = [
                Double(conf.0.x), Double(conf.0.y),
                Double(conf.1.x), Double(conf.1.y),
            ]
            let vecB: [Double] = [
                Double(add + conf.2.x),
                Double(add + conf.2.y)
            ]
            if let result = solveSystemOfEquations(a: matA, b: vecB) {
                let a = result[0]
                let b = result[1]
                if !a.isApproximatelyEqual(to: a.rounded(), absoluteTolerance: 0.001)
                    || !b.isApproximatelyEqual(to: b.rounded(), absoluteTolerance: 0.001)
                {
                    continue  // not a valid solution
                }
                total += 3 * Int(a.rounded()) + Int(b.rounded())
            }
        }
        return total
    }

    override func part1(_ input: [String]) -> String {
        return String(solve(input))
    }

    override func part2(_ input: [String]) -> String {
        return String(solve(input, add: 10_000_000_000_000))
    }
}
