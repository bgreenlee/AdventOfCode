//
//  PrintQueue.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/5/24.
//

class PrintQueue: Solution {
    init() {
        super.init(id: 5, name: "Print Queue")
    }

    func parseInput(_ input: [String]) -> ([[Int]], [[Int]]) {
        let splitIndex = input.firstIndex(of: "")!
        let rulesInput = input[..<splitIndex]
        let updatesInput = input[splitIndex.advanced(by: 1)...]
        let rules = rulesInput.map { $0.split(separator: "|").map { Int($0)! }}
        let updates = updatesInput.map { $0.split(separator: ",").map { Int($0)! }}
        return (rules, updates)
    }

    // returns a sort function based on the given rules
    func rulesSorter(_ rules: [[Int]]) -> (Int, Int) -> Bool {
        {
            (a: Int, b: Int) -> Bool in
                for rule in rules {
                    if a == rule[0] && b == rule[1] {
                        return true
                    }
                }
                return false
        }
    }

    override func part1(_ input: [String]) -> String {
        let (rules, updates) = parseInput(input)

        var sum = 0
        for update in updates {
            let sortedUpdate = update.sorted(by: rulesSorter(rules))
            if sortedUpdate == update {
                sum += update[update.count / 2]
            }
        }
        return String(sum)
    }

    override func part2(_ input: [String]) -> String {
        let (rules, updates) = parseInput(input)

        var sum = 0
        for update in updates {
            let sortedUpdate = update.sorted(by: rulesSorter(rules))
            if sortedUpdate != update {
                sum += sortedUpdate[sortedUpdate.count / 2]
            }
        }
        return String(sum)
    }
}
