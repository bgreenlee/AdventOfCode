//
//  Solution.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/1/24.
//
import Foundation

struct SolutionAnswer: Hashable {
    var answer: String
    var executionTime: Duration

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
    let inputs: [Input]
    @Published var selectedInput: Input?
    @Published var answers: [SolutionPart: SolutionAnswer] = [:]
    var aocUrl: String {
        return "https://adventofcode.com/2024/day/\(id)"
    }
    var githubUrl: String {
        return "https://github.com/bgreenlee/AdventOfCode/blob/main/2024/AdventOfCode/Solutions/Day%20\(id)/\(String(describing: type(of: self))).swift"
    }

    init(id: Int, name: String) {
        self.id = id
        self.name = name
        self.inputs = Input.load(day: id)
    }

    static func == (lhs: Solution, rhs: Solution) -> Bool {
        return lhs.id == rhs.id && lhs.answers == rhs.answers
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(answers)
    }

    func run(_ part: SolutionPart, file: String) {
        let clock = ContinuousClock()
        let input = selectedInput?.lines ?? []
        var result: String = ""
        var time: Duration
        switch part {
        case .part1:
            time = clock.measure {
                result = part1(input)
            }
        case .part2:
            time = clock.measure {
                result = part2(input)
            }
        }
        self.answers[part] = SolutionAnswer(answer: result, executionTime: time)
    }

    func part1(_ input: [String]) -> String {
        return "unimplemented"
    }

    func part2(_ input: [String]) -> String {
        return "unimplemented"
    }
}
