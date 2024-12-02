//
//  RedNosedReports.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/2/24.
//
import Foundation

struct RedNosedReports: Solution {
    let id = UUID()
    let name = "Red-Nosed Reports"
    let day = 2
    var input: [String]

    init() {
        self.input = Input.load(day: day)
    }

    // generate a list of diffs between each number
    func getDiffs(_ nums: [Int]) -> [Int] {
        if nums.count < 2 { return [] }

        var diffs: [Int] = []
        for i in 1..<nums.count {
            diffs.append(nums[i] - nums[i-1])
        }
        return diffs
    }

    func isSafe(_ nums: [Int]) -> Bool {
        let diffs = getDiffs(nums)
        return diffs.allSatisfy({ $0 > 0 && $0 <= 3}) || diffs.allSatisfy({ $0 < 0 && $0 >= -3 })
    }

    func isSafeLine(_ line: String) -> Bool {
        let nums = line.split(separator: " ").map { Int($0)! }
        return isSafe(nums)
    }

    func part1() -> String {
        return String(input.count(where: isSafeLine))
    }

    func part2() -> String {
        var numSafe = input.count(where: isSafeLine) // these are safe without removing anything
        // test the unsafe lines
        let maybeUnsafe = input.filter { !isSafeLine($0) }
        for line in maybeUnsafe {
            let nums = line.split(separator: " ").map { Int($0)! }
            for i in 0..<nums.count {
                // remove the element at this index and test the rest
                let newNums = nums.enumerated().filter { (j, _) in j != i }.map(\.element)
                if isSafe(newNums) {
                    numSafe += 1
                    break
                }
            }
        }
        return "\(numSafe)"
    }
}
