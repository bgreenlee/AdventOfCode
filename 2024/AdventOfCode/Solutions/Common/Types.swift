//
//  Types.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/10/24.
//

typealias Point = SIMD2<Int>
typealias Vector = SIMD2<Int>

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

extension Vector {
    static let north = Vector(0, -1)
    static let east = Vector(1, 0)
    static let south = Vector(0, 1)
    static let west = Vector(-1, 0)
}
