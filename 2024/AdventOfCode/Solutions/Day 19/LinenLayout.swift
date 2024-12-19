//
//  LinenLayout.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/19/24.
//

class LinenLayout: Solution {
    init() {
        super.init(id: 19, name: "Linen Layout", hasDisplay: false)
    }

    func parseInput(_ input: [String]) -> ([String], [String]) {
        let towels = input[0].split(separator: ",").map({ $0.trimmingCharacters(in: .whitespaces) })
        let patterns = input[2...]

        return (towels, Array(patterns))
    }

    // part 1: recursively match the string and patterns
    func match(_ pattern: String, _ towels: [String], _ cache: inout [String: Bool]) -> Bool {
        if let cached = cache[pattern] {
            return cached
        }
        for towel in towels {
            if pattern == towel {
                cache[pattern] = true
                return true
            } else if pattern.starts(with: towel) {
                let strRemaining = String(pattern[pattern.index(pattern.startIndex, offsetBy: towel.count)...])
                cache[pattern] = match(strRemaining, towels, &cache)
                if cache[pattern]! {
                    return true
                }
            }
        }
        return false
    }

    override func part1(_ input: [String]) -> String {
        let (towels, patterns) = parseInput(input)

        // this actually hangs; bug report: https://github.com/swiftlang/swift-experimental-string-processing/issues/793
        // let towelRE = try! Regex("(?U)^(?:\(towels.joined(separator: "|")))+$")
        // let count = patterns.filter({ $0.wholeMatch(of: towelRE) != nil }).count

        let count = patterns.filter({
            var cache: [String: Bool] = [:]
            return match($0, towels, &cache)
        }).count
        return String(count)
    }

    // part 2: recursively match the string and patterns, returning the total number of possible matches
    func matchCount(_ pattern: String, _ towels: [String],  _ cache: inout [String: Int]) -> Int {
        if let cached = cache[pattern] {
            return cached
        }
        var numMatches = 0
        for towel in towels {
            if pattern == towel {
                numMatches += 1
            } else if pattern.starts(with: towel) {
                let strRemaining = String(pattern[pattern.index(pattern.startIndex, offsetBy: towel.count)...])
                numMatches += matchCount(strRemaining, towels, &cache)
            }
        }
        cache[pattern] = numMatches
        return numMatches
    }

    override func part2(_ input: [String]) -> String {
        let (towels, patterns) = parseInput(input)
        let count = patterns.reduce(0) { acc, pattern in
            var cache: [String: Int] = [:]
            return acc + matchCount(pattern, towels, &cache)
        }
        return String(count)
    }
}
