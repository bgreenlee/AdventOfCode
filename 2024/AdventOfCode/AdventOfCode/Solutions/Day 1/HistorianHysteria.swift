//
//  HistorianHysteria.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/1/24.
//

import Foundation

struct HystorianHysteria {
    static func part1() -> String {
        var left: [Int] = []
        var right: [Int] = []
        do {
            let filePath = Bundle.main.path(forResource: "input", ofType: "dat", inDirectory: "Inputs/Day 1")!
            let data = try String(contentsOfFile: filePath, encoding: .utf8)
            let lines = data.components(separatedBy: .newlines)
            for line in lines {
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
        } catch {
            return "Error reading file: \(error)"
        }
    }

    static func part2() -> String {
        var left: [Int] = []
        var right: [Int:Int] = [:]
        do {
            let filePath = Bundle.main.path(forResource: "input", ofType: "dat", inDirectory: "Inputs/Day 1")!
            let data = try String(contentsOfFile: filePath, encoding: .utf8)
            let lines = data.components(separatedBy: .newlines)
            for line in lines {
                let nums = line.split(separator: " ").map { Int($0)! }
                left.append(nums[0])
                right[nums[1], default: 0] += 1
            }
            var score = 0
            for i in 0..<left.count {
                score += left[i] * right[left[i], default: 0]
            }
            return "\(score)"
        } catch {
            return "Error reading file: \(error)"
        }
    }

}
