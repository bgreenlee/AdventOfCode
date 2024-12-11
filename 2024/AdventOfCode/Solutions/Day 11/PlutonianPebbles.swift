//
//  PlutonianPebbles.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/11/24.
//
import Foundation

class PlutonianPebbles: Solution {
    init() {
        super.init(id: 11, name: "Plutonian Pebbles", hasDisplay: true)
    }

    func count(_ num: Int, _ iterations: Int) -> Int {
        if iterations == 0 {
            return 1
        }
        if num == 0 {
            return count(1, iterations - 1)
        } else {
            let len = Int(log10(Float(num)) + 1) // length of number
            if len % 2 == 0 {
                let divisor = Int(pow(10, Float(len / 2)))
                let (left, right) = (num / divisor, num % divisor)
                return count(left, iterations - 1) + count(right, iterations - 1)
            }
        }
        return count(num * 2024, iterations - 1)
    }

    func solve(_ nums: [Int], _ iterations: Int) -> Int {
        nums.reduce(0) { acc, num in acc + count(num, iterations) }
    }

    override func part1(_ input: [String]) -> String {
        let nums = input[0].split(separator: " ").map { Int($0)! }
        return String(solve(nums, 25))
    }

    override func part2(_ input: [String]) -> String {
        let nums = input[0].split(separator: " ").map { Int($0)! }
        return String(solve(nums, 45))
    }
}
