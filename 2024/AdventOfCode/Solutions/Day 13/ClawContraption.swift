//
//  ClawContraption.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/13/24.
//
import Numerics
import Accelerate.vecLib.LinearAlgebra

class ClawContraption: Solution {
    init() {
        super.init(id: 13, name: "Claw Contraption", hasDisplay: false)
    }

    func parseInput(_ input: [String]) -> [([Double], [Double])] {
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
                // matrix of coefficients
                [
                    Double($0.1)!, Double($0.2)!,
                    Double($0.3)!, Double($0.4)!,
                ],
                // vector of answers
                [
                    Double($0.5)!,
                    Double($0.6)!,
                ]
            )
        }
    }

    // from https://developer.apple.com/documentation/accelerate/solving_systems_of_linear_equations_with_lapack
    func solveSystemOfEquations(_ a: [Double], _ b: [Double]) -> [Double]? {
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
        for (matA, vecB) in configurations {
            let vecB = vecB.map { $0 + Double(add) }
            if let result = solveSystemOfEquations(matA, vecB) {
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
