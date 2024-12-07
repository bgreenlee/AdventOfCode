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

    // generate all combinations of operators filling k positions
    func generate(_ operators: [Character], _ k: Int) -> [[Character]] {
        guard k > 0 else { return [] }

        var result = operators.map { [$0] }

        for _ in 1..<k {
            result = result.flatMap { combo in
                operators.map { op in
                    combo + [op]
                }
            }
        }

        return result
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
        let operators: [Character] = ["+", "*"]
        var result = 0
        for (testValue, numbers) in equations {
            for opPermutation in generate(operators, numbers.count - 1) {
                if calculate(numbers, opPermutation) == testValue {
                    result += testValue
                    break
                }
            }
        }
        return String(result)
    }

    override func part2(_ input: [String]) -> String {
        let equations = parseInput(input)
        let operators: [Character] = ["+", "*", "|"]
        var result = 0
        for (testValue, numbers) in equations {
            for opPermutation in generate(operators, numbers.count - 1) {
                if calculate(numbers, opPermutation) == testValue {
                    result += testValue
                    break
                }
            }
        }
        return String(result)
    }
}
