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
        private var cache: [Int: [[Character]]] = [:] // cache of results for each k
        private let operators: [Character]

        init(_ operators: [Character]) {
            self.operators = operators
        }

        mutating func generate(_ k: Int) -> [[Character]] {
            if let cached = cache[k] {
                return cached
            }

            guard k > 0 else { return [] }

            var result = operators.map { [$0] }

            cache[1] = result // cache single-operator result

            for length in 2...k {
                result = result.flatMap { combo in
                    operators.map { op in
                        combo + [op]
                    }
                }
                cache[length] = result
            }

            return result
        }
    }

    func calculate(_ numbers: [Int], _ operators: [Character]) -> Int {
        var result = 0
        let operators = ["+"] + operators
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

    override func part1(_ input: [String]) -> String {
        let equations = parseInput(input)
        var opGenerator = OperatorCombinationsGenerator(["+", "*"])
        var result = 0
        for (testValue, numbers) in equations {
            for ops in opGenerator.generate(numbers.count - 1) {
                if calculate(numbers, ops) == testValue {
                    result += testValue
                    break
                }
            }
        }
        return String(result)
    }

    override func part2(_ input: [String]) -> String {
        let equations = parseInput(input)
        var opGenerator = OperatorCombinationsGenerator(["+", "*", "|"])
        var result = 0
        for (testValue, numbers) in equations {
            for ops in opGenerator.generate(numbers.count - 1) {
                if calculate(numbers, ops) == testValue {
                    result += testValue
                    break
                }
            }
        }
        return String(result)
    }
}
