//
//  MullItOver.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/3/24.
//
import Foundation

class MullItOver: Solution {
    init() {
        super.init(id: 3, name: "Mull It Over")
    }

    override func part1(_ input: [String]) -> String {
        let matches = input
            .joined()
            .matches(of: /mul\((\d+),(\d+)\)/)
        let sum = matches
            .reduce(0) {
                $0 + Int($1.1)! * Int($1.2)!
            }
        return String(sum)
    }

    override func part2(_ input: [String]) -> String {
        let matches = input
            .joined()
            .matches(of: /do\(\)|don't\(\)|mul\((\d+),(\d+)\)/)

        var sum = 0
        var enabled = true
        for match in matches {
            switch match.output.0 {
            case "do()":
                enabled = true
            case "don't()":
                enabled = false
            default:
                if enabled {
                    sum += Int(match.1!)! * Int(match.2!)!
                }
            }
        }
        return String(sum)
    }
}
