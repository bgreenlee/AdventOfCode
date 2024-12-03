//
//  HistorianHysteria.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/1/24.
//
import Foundation

struct HistorianHysteria: Solution {
    var id = 1
    var name = "Historian Hysteria"
    var input: [String]
    var executionTime: TimeInterval?

    init() {
        self.input = Input.load(day: id)
    }

    mutating func run(_ part: SolutionPart) -> String {
        let start = Date()
        let result = switch part {
        case .part1:
            part1()
        case .part2:
            part2()
        }
        self.executionTime = Date().timeIntervalSince(start)
        return result
    }

    func part1() -> String {
        var left: [Int] = []
        var right: [Int] = []
        for line in input {
            let nums = line.split(separator: " ").map { Int($0)! }
            left.append(nums[0])
            right.append(nums[1])
        }
        left.sort()
        right.sort()
        var sum = 0
        for i in 0..<left.count {
            sum += abs(left[i] - right[i])
        }
        return "\(sum)"
    }

    func part2() -> String {
        var left: [Int] = []
        var right: [Int:Int] = [:]
        for line in input {
            let nums = line.split(separator: " ").map { Int($0)! }
            left.append(nums[0])
            right[nums[1], default: 0] += 1
        }
        var score = 0
        for i in 0..<left.count {
            score += left[i] * right[left[i], default: 0]
        }
        return "\(score)"
    }
}
