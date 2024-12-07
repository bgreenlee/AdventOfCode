//
//  BridgeRepair.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/7/24.
//

class BridgeRepair: Solution {
    init() {
        super.init(id: 7, name: "Bridge Repair")
    }

    func parseInput(_ input: [String]) -> [(Int, [Int])] {
        var equations: [(Int, [Int])] = []
        for line in input {
            let parts = line.split(separator: ": ")
            let testValue = Int(parts[0])!
            let numbers = parts[1].split(separator: " ").map { Int($0)! }
            equations.append((testValue, numbers))
        }
        return equations
    }

    func concat(_ a: Int, _ b: Int) -> Int {
        Int(String(a) + String(b))!
    }

    // mcfunley's clever solution
    func solve(_ acc: Int, _ result: Int, _ numbers: [Int], _ operators: [(Int, Int) -> Int]) -> Int
    {
        if numbers.isEmpty {
            return acc == result ? result : 0
        }
        let n = numbers[0]
        let rest = Array(numbers[1...])

        return operators.map { op in
            solve(op(acc, n), result, rest, operators)
        }.first(where: { $0 > 0 }) ?? 0
    }

    override func part1(_ input: [String]) -> String {
        let equations = parseInput(input)
        var result = 0
        for (testValue, numbers) in equations {
            result += solve(numbers[0], testValue, Array(numbers[1...]), [(+), (*)])
        }
        return String(result)
    }

    override func part2(_ input: [String]) -> String {
        let equations = parseInput(input)
        var result = 0
        for (testValue, numbers) in equations {
            result += solve(numbers[0], testValue, Array(numbers[1...]), [(+), (*), concat])
        }
        return String(result)
    }
}
