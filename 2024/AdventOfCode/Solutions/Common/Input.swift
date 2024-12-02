//
//  Input.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/1/24.
//

import Foundation

// Utility for handling file input
struct Input {
    static func load(day: Int, name: String = "input") -> [String] {
        do {
            let filePath = Bundle.main.path(forResource: name, ofType: "dat", inDirectory: "Inputs/Day \(day)")!
            var data = try String(contentsOfFile: filePath, encoding: .utf8)
            data = data.trimmingCharacters(in: .newlines) // remove trailing newlines
            let lines = data.components(separatedBy: .newlines)
            return lines
        } catch {
            print("Could not load file \(name).dat for day \(day)")
            return []
        }
    }
}
