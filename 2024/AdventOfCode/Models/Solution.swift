//
//  Solution.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/1/24.
//
import Foundation

struct SolutionAnswer: Hashable {
    var answer: String
    var executionTime: TimeInterval

    static func == (lhs: SolutionAnswer, rhs: SolutionAnswer) -> Bool {
        return lhs.answer == rhs.answer
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(answer)
    }
}

enum SolutionPart: String {
    case part1 = "Part 1"
    case part2 = "Part 2"
}

class Solution: ObservableObject, Identifiable, Hashable {
    let id: Int
    let name: String
    var input: [String]
    var answers: [SolutionPart: SolutionAnswer] = [:]

    init(id: Int, name: String) {
        self.id = id
        self.name = name
        self.input = Input.load(day: id)
    }

    static func == (lhs: Solution, rhs: Solution) -> Bool {
        return lhs.id == rhs.id && lhs.answers == rhs.answers
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(answers)
    }

    func run(_ part: SolutionPart) {
        let start = Date()
        let result = switch part {
        case .part1:
            part1()
        case .part2:
            part2()
        }
        self.answers[part] = SolutionAnswer(answer: result, executionTime: Date().timeIntervalSince(start))
        self.objectWillChange.send()
    }

    func part1() -> String {
        return "unimplemented"
    }

    func part2() -> String {
        return "unimplemented"
    }
}
