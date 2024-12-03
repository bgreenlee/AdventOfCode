//
//  Solution.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/1/24.
//
import Foundation

protocol Solution: Identifiable, Hashable {
    var id: Int { get set } // day
    var name: String { get set }
    var input: [String] { get set }

    func part1() -> String
    func part2() -> String
}

// this is annoying but necessary for "any Solution" to conform to Identifiable
struct AnySolution: Solution {
    private var _solution: any Solution

    init(_ solution: some Solution) {
        _solution = solution // Automatically casts to “any” type
    }

    var id: Int {
        get { _solution.id }
        set { _solution.id = newValue }
    }

    var name: String {
        get { _solution.name }
        set { _solution.name = newValue }
    }

    var input: [String] {
        get { _solution.input }
        set { _solution.input = newValue }
    }

    func part1() -> String {
        _solution.part1()
    }

    func part2() -> String {
        _solution.part2()
    }
}

extension AnySolution: Equatable {
    static func == (lhs: AnySolution, rhs: AnySolution) -> Bool {
        return lhs._solution.id == rhs._solution.id
    }
}

extension AnySolution: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
