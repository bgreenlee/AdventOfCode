//
//  PrintQueue.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/5/24.
//

typealias Rule = SIMD2<Int>

class PrintQueue: Solution {
    init() {
        super.init(id: 5, name: "Print Queue")
    }

    func parseInput(_ input: [String]) -> (Set<Rule>, [[Int]]) {
        let splitIndex = input.firstIndex(of: "")!
        let rulesInput = input[..<splitIndex]
        let updatesInput = input[splitIndex.advanced(by: 1)...]
        let rules = Set(
            rulesInput.map {
                let parts = $0.split(separator: "|")
                return Rule(Int(parts[0])!, Int(parts[1])!)
            }
        )
        let updates = updatesInput.map { $0.split(separator: ",").map { Int($0)! } }
        return (rules, updates)
    }

    override func part1(_ input: [String]) -> String {
        let (rules, updates) = parseInput(input)

        var sum = 0
        for update in updates {
            let sortedUpdate = update.sorted { rules.contains(Rule($0, $1)) }
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
            let sortedUpdate = update.sorted { rules.contains(Rule($0, $1)) }
            if sortedUpdate != update {
                sum += sortedUpdate[sortedUpdate.count / 2]
            }
        }
        return String(sum)
    }
}
