//
//  ChronospatialComputer.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/17/24.
//
import Foundation

class ChronospatialComputer: Solution {
    init() {
        super.init(id: 17, name: "Chronospatial Computer", hasDisplay: false)
    }

    func parseInput(_ input: [String]) -> (Int, Int, Int, [Int]) {
        if let match = input.joined().wholeMatch(
            of: /Register A: (\d+).*?Register B: (\d+).*?Register C: (\d+).*?Program: ([\d,]+)/)
        {
            let regA = Int(match.1)!
            let regB = Int(match.2)!
            let regC = Int(match.3)!
            let program = match.4.split(separator: ",").map { Int($0)! }
            return (regA, regB, regC, program)
        }
        fatalError("Could not parse input")
    }

    func runProgram(_ regA: Int, _ regB: Int, _ regC: Int, _ program: [Int]) -> [Int] {
        var regA = regA
        var regB = regB
        var regC = regC
        var i: Int = 0  // instruction pointer
        var output: [Int] = []

        func combo(_ operand: Int) -> Int {
            return switch operand {
            case 0...3:
                operand
            case 4:
                regA
            case 5:
                regB
            case 6:
                regC
            default:
                fatalError("Illegal operand: \(operand)")
            }
        }

        while i < program.count {
            let (instr, operand) = (program[i], program[i + 1])
            switch instr {
            case 0:  // adv
                regA /= Int(pow(2, Double(combo(operand))))
            case 1:  // bxl
                regB ^= operand
            case 2:  // bst
                regB = combo(operand) % 8
            case 3:  // jnz
                if regA > 0 {
                    i = operand
                    continue
                }
            case 4:  // bxc
                regB ^= regC
            case 5:  // out
                output.append(combo(operand) % 8)
            case 6:  // bdv
                regB = regA / Int(pow(2, Double(combo(operand))))
            case 7:  // cdv
                regC = regA / Int(pow(2, Double(combo(operand))))
            default:
                fatalError("Illegal instruction: \(instr)")
            }

            i += 2
        }

        return output
    }

    override func part1(_ input: [String]) -> String {
        let (regA, regB, regC, program) = parseInput(input)
        let output = runProgram(regA, regB, regC, program)
        return output.map({ String($0) }).joined(separator: ",")
    }

    override func part2(_ input: [String]) -> String {
        let (_, regB, regC, program) = parseInput(input)
        var i = 1
        var j = 1
        while j < program.count {
            let output = runProgram(i, regB, regC, program)
            // compare last j digits...if they match, go up an order of magnitude
            if output[(output.count - j)...] == program[(program.count - j)...] {
                i *= 8
                j += 1
            } else {
                i += 1
            }
        }
        return String(i)
    }
}
