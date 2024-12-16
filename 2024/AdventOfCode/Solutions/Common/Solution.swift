//
//  Solution.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/1/24.
//
import Foundation

struct SolutionAnswer {
    var answer: String
    var executionTime: Duration
}

extension SolutionAnswer: Hashable {
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

class Solution: ObservableObject, Identifiable {
    let id: Int
    let name: String
    let inputs: [Input]
    let hasDisplay: Bool
    var frames: [SolutionPart: [String]] = [:]  // display frames
    @MainActor @Published var selectedInput: Input?
    @MainActor @Published var answers: [SolutionPart: SolutionAnswer] = [:]

    var aocUrl: String {
        return "https://adventofcode.com/2024/day/\(id)"
    }
    var githubUrl: String {
        return "https://github.com/bgreenlee/AdventOfCode/blob/main/2024/AdventOfCode/Solutions/Day%20\(id)/\(String(describing: type(of: self))).swift"
    }

    init(id: Int, name: String, hasDisplay: Bool = false) {
        self.id = id
        self.name = name
        self.inputs = Input.load(day: id)
        self.hasDisplay = hasDisplay
    }

    func run(_ part: SolutionPart, file: String) async -> SolutionAnswer {
        let clock = ContinuousClock()
        let input = await selectedInput?.lines ?? []
        var result: String = ""
        var time: Duration
        frames[part] = []
        switch part {
        case .part1:
            time =  clock.measure {
                result = part1(input)
            }
        case .part2:
            time = clock.measure {
                result = part2(input)
            }
        }
        return SolutionAnswer(answer: result, executionTime: time)
    }

    func addFrame(part: SolutionPart, _ frame: String) {
        frames[part, default: []].append(frame)
    }

    @MainActor
    func updateUI(part: SolutionPart, answer: SolutionAnswer) {
        self.answers[part] = answer
    }

    func part1(_ input: [String]) -> String {
        return "unimplemented"
    }

    func part2(_ input: [String]) -> String {
        return "unimplemented"
    }
}

extension Solution: Hashable {
    static func == (lhs: Solution, rhs: Solution) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
