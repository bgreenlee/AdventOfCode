//
//  Solution.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/1/24.
//

protocol Solution {
    var day: Int { get }
    var input: [String] { get set }

    init()
    func part1() -> String
    func part2() -> String
}
