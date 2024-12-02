//
//  Solution.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/1/24.
//
import Foundation

protocol Solution: Identifiable {
    var id: UUID { get }
    var name: String { get }
    var day: Int { get }
    var input: [String] { get set }

    init()
    func part1() -> String
    func part2() -> String
}
