//
//  Solution.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/1/24.
//
import Foundation

protocol Solution: Identifiable, Hashable {
    var id: Int { get } // day
    var name: String { get }
    var input: [String] { get set }

    func part1() -> String
    func part2() -> String
}
