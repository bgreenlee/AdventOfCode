//
//  HistorianHysteria.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/1/24.
//
import Foundation

struct HystorianHysteria: Solution {
    let id = UUID()
    let name = "Historian Hysteria"
    let day = 1
    var input: [String]

    init() {
        self.input = Input.load(day: day)
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
