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

    func matchPattern(_ pattern: String, _ towelRE: Regex<AnyRegexOutput>) async -> Bool {
        let result = try! towelRE.wholeMatch(in: pattern) != nil
        print("\(pattern): \(result)")
        return result
    }

    func matchPatterns(_ patterns: [String], _ towelRE: Regex<AnyRegexOutput>) async -> Int {
        await withTaskGroup(of: Bool.self) { group in
            for pattern in patterns {
                group.addTask {
                    await self.matchPattern(pattern, towelRE)
                }
            }
            var count = 0
            var resultCount = 0
            for await result in group {
                resultCount += 1
                print("\(resultCount)/\(patterns.count)")
                count += result ? 1 : 0
            }
            return count
        }
    }

    override func part1(_ input: [String]) -> String {
        let (towels, patterns) = parseInput(input)
        let towelRE = try! Regex("^(\(towels.joined(separator: "|")))+$")
//         let count = patterns.filter({ try! towelRE.wholeMatch(in: $0) != nil }).count
        var count = 0
        for (i, pattern) in patterns.enumerated() {
            print("\(i + 1)/\(patterns.count): \(pattern)")
            if pattern.firstMatch(of: towelRE) != nil {
                count += 1
            }
        }
//        Task {
//            let count = await matchPatterns(patterns, towelRE)
//            print("Answer: \(count)")
//        }
        return String(count)
    }

    override func part2(_ input: [String]) -> String {
        return ""
    }
}
