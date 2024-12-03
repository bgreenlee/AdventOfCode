//
//  Solution.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/1/24.
//
import Foundation

class Solution: Identifiable, Hashable {
    let id: Int
    let name: String
    var input: [String]
    var executionTime: TimeInterval?

    init(id: Int, name: String) {
        self.id = id
        self.name = name
        self.input = Input.load(day: id)
    }

    static func == (lhs: Solution, rhs: Solution) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func run(_ part: SolutionPart) -> String {
        let start = Date()
        let result = switch part {
        case .part1:
            part1()
        case .part2:
            part2()
        }
        self.executionTime = Date().timeIntervalSince(start)
        return result
    }

    func part1() -> String {
        return "unimplemented"
    }

    func part2() -> String {
        return "unimplemented"
    }
}

enum SolutionPart {
    case part1
    case part2
}
