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

    struct OperatorCombinationsGenerator {
        private var cache: [Int: [[Character]]] = [:]  // cache of results for each k
        private let operators: [Character]

        init(_ operators: [Character]) {
            self.operators = operators
        }

        // generate all combinations of operators filling k slots
        mutating func generate(_ k: Int) -> [[Character]] {
            if let cached = cache[k] {
                return cached
            }

            // base cases
            guard k > 0 else { return [] }
            if k == 1 {
                let result = operators.map { [$0] }
                cache[1] = result
                return result
            }

            // get combinations for k-1 positions and append each operator
            let previousCombos = generate(k - 1)
            let result = previousCombos.flatMap { combo in
                operators.map { op in
                    combo + [op]
                }
            }

            cache[k] = result
            return result
        }
    }

    // given a list of n numbers and n - 1 operators, calculate the result
    func calculate(_ numbers: [Int], _ operators: [Character]) -> Int {
        guard numbers.count - operators.count == 1 else { return 0 }

        var result = 0
        let operators = ["+"] + operators  // add a leading + so that we can zip
        for (num, op) in zip(numbers, operators) {
            switch op {
            case "+": result += num
            case "*": result *= num
            case "|": result = Int(String(result) + String(num))!
            default: break
            }
        }
        return result
    }

    // given a list of equations and a set of operators, return the sum of all equations
    // that can be satisfied by some combination of operators
    func scoreValidValues(_ equations: [(Int, [Int])], _ operators: [Character]) -> Int {
        var opGenerator = OperatorCombinationsGenerator(operators)
        var result = 0
        for (testValue, numbers) in equations {
            for ops in opGenerator.generate(numbers.count - 1) {
                if calculate(numbers, ops) == testValue {
                    result += testValue
                    break
                }
            }
        }
        return result
    }

    override func part1(_ input: [String]) -> String {
        let equations = parseInput(input)
        let result = scoreValidValues(equations, ["+", "*"])
        return String(result)
    }

    override func part2(_ input: [String]) -> String {
        let equations = parseInput(input)
        let result = scoreValidValues(equations, ["+", "*", "|"])
        return String(result)
    }
}
