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

    // this actually hangs; bug report: https://github.com/swiftlang/swift-experimental-string-processing/issues/793
    override func part1(_ input: [String]) -> String {
        let (towels, patterns) = parseInput(input)
        let towelRE = try! Regex("(?U)^(?:\(towels.joined(separator: "|")))+$")
        let count = patterns.filter({ $0.wholeMatch(of: towelRE) != nil }).count
        return String(count)
    }

    // recursively match the string and patterns
    var cache: [String: Int] = [:]
    func matchCount(_ pattern: String, _ towels: [String], _ numMatches: Int = 0) -> Int {
        if cache[pattern] != nil {
            return cache[pattern]!
        }

        if pattern == "" {
            return numMatches + 1
        }

        var numMatches = numMatches
        for towel in towels {
            if towel.count > pattern.count {
                continue
            }
            if pattern.starts(with: towel) {
                let strRemaining = String(pattern[pattern.index(pattern.startIndex, offsetBy: towel.count)...])
                cache[strRemaining] = matchCount(strRemaining, towels)
                numMatches += cache[strRemaining]!
            }
        }
        return numMatches
    }

    override func part2(_ input: [String]) -> String {
        let (towels, patterns) = parseInput(input)
        let count = patterns.reduce(0) { acc, pattern in
            cache = [:] // clear the cache for each one
            return acc + matchCount(pattern, towels, 0)
        }
        return String(count)
    }
}
