//
//  CrossedWires.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/31/24.
//

class CrossedWires: Solution {
    init() {
        super.init(id: 24, name: "Crossed Wires", hasDisplay: true)
    }

    struct Instruction {
        let a: String
        let op: String
        let b: String
        let dest: String
        var completed: Bool = false

        init(_ line: String) {
            let parts = line.split(separator: " ")
            a = String(parts[0])
            op = String(parts[1])
            b = String(parts[2])
            dest = String(parts[4])
        }

        func evaluate(_ register: [String: Int]) -> Int? {
            if let aval = register[a], let bval = register[b] {
                return switch op {
                case "AND": aval & bval
                case "OR": aval | bval
                case "XOR": aval ^ bval
                default: nil
                }
            }
            return nil
        }
    }

    override func part1(_ input: [String]) -> String {
        let splitIndex = input.firstIndex(of: "")!
        let registerStrs = input[..<splitIndex]
        let instructionStrs = input[splitIndex.advanced(by: 1)...]

        var register: [String: Int] = [:]
        for registerStr in registerStrs {
            let parts = registerStr.split(separator: ": ")
            register[String(parts[0])] = Int(parts[1])!
        }

        var instructions = instructionStrs.map { Instruction(String($0)) }
        while !instructions.allSatisfy({ $0.completed }) {
            for i in 0..<instructions.count {
                if !instructions[i].completed, let result = instructions[i].evaluate(register) {
                    register[instructions[i].dest] = result
                    instructions[i].completed = true
                }
            }
        }

        let bits =
            register
            .filter({ $0.key.starts(with: "z") })
            .sorted(by: { a, b in a.key > b.key })
            .map({ String($0.value) })
            .joined()

        return String(Int(bits, radix: 2)!)
    }

    // This isn't a complete solution. I used this code to find where the four problem areas
    // were and then figured out the swaps by hand
    override func part2(_ input: [String]) -> String {
        let splitIndex = input.firstIndex(of: "")!
        let registerStrs = input[..<splitIndex]
        let instructionStrs = input[splitIndex.advanced(by: 1)...]

        var register: [String: Int] = [:]
        for registerStr in registerStrs {
            let parts = registerStr.split(separator: ": ")
            register[String(parts[0])] = Int(parts[1])!
        }

        let instructions = instructionStrs.map { Instruction(String($0)) }

        // get number of bits
        let maxx = register.keys.filter({ $0.starts(with: "x") }).max()!
        let numbits = Int(maxx.dropFirst())!

        var swapped: [String] = []
        for i in 0..<numbits {
            let numstr = String(format: "%02d", i)
            let xreg = "x\(numstr)"
//            let yreg = "y\(numstr)"
            let zreg = "z\(numstr)"

            print(xreg)
            let xxor = instructions.first(where: {
                $0.op == "XOR" && ($0.a == xreg || $0.b == xreg)
            })!
            if xxor.dest == zreg {
                continue
            }
            if let destxor = instructions.first(where: {
                $0.op == "XOR" && ($0.a == xxor.dest || $0.b == xxor.dest)
            }) {
                // output of this should be zxx
                if destxor.dest != zreg {
                    print("\(xreg) -> \(xxor.dest) -> \(destxor.dest)")
                    swapped.append(contentsOf: [destxor.dest, zreg])
                }
            } else {
                print(xxor)
                swapped.append(contentsOf: [xxor.dest, zreg])
            }
        }
        let result = swapped.sorted().joined(separator: ",")
        return result
    }
}
