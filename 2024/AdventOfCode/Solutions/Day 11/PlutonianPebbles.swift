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

    func split(_ num: Int) -> (Int, Int) {
        let len = log10(Double(num)).rounded(.down) + 1
        let divisor = Int(pow(10, len / 2))
        return (num / divisor, num % divisor)
    }

    func solve(_ nums: [Int], _ iterations: Int) -> Int {
        var nums = nums
        print("\(0): \(nums) \(nums.count)")
        for i in 1...iterations {
            let newNums = nums.flatMap { num in
                if num == 0 {
                    return [1]
                } else {
                    let len = log10(Double(num)).rounded(.down) + 1
                    if len.truncatingRemainder(dividingBy: 2) == 0 {
                        let divisor = Int(pow(10, len / 2))
                        return [num / divisor, num % divisor]
                    }
                    return [num * 2024]
                }
            }
            nums = newNums
            print("\(i): \(nums) \(nums.count)")
        }
        return nums.count
    }

    override func part1(_ input: [String]) -> String {
        let nums = input[0].split(separator: " ").map { Int($0)! }
        return String(solve(nums, 25))
    }

    override func part2(_ input: [String]) -> String {
        let nums = input[0].split(separator: " ").map { Int($0)! }
        return String(solve(nums, 25))
    }
}
