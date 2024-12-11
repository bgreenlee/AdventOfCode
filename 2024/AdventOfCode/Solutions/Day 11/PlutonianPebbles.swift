//
//  PlutonianPebbles.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/11/24.
//
import Foundation

class PlutonianPebbles: Solution {
    init() {
        super.init(id: 11, name: "Plutonian Pebbles", hasDisplay: false)
    }

    typealias Tuple = SIMD2<Int>
    typealias Cache = [Tuple: Int]

    func count(_ num: Int, _ iterations: Int, _ cache: inout Cache) -> Int {
        // check cache
        if let result = cache[Tuple(num, iterations)] {
            return result
        }

        // base case
        if iterations == 0 {
            return 1
        }

        // recurse
        var result = 0
        if num == 0 {
            result = count(1, iterations - 1, &cache)
        } else {
            let len = Int(log10(Float(num))) + 1 // length of number
            if len % 2 == 0 {
                let divisor = Int(pow(10, Float(len / 2)))
                let (left, right) = (num / divisor, num % divisor)
                result = count(left, iterations - 1, &cache) + count(right, iterations - 1, &cache)
            } else {
                result = count(num * 2024, iterations - 1, &cache)
            }
        }
        cache[Tuple(num, iterations)] = result
        return result
    }

    func solve(_ nums: [Int], _ iterations: Int) -> Int {
        var cache: Cache = [:]
        return nums.reduce(0) { acc, num in acc + count(num, iterations, &cache) }
    }

    override func part1(_ input: [String]) -> String {
        let nums = input[0].split(separator: " ").map { Int($0)! }
        return String(solve(nums, 25))
    }

    override func part2(_ input: [String]) -> String {
        let nums = input[0].split(separator: " ").map { Int($0)! }
        return String(solve(nums, 75))
    }
}
