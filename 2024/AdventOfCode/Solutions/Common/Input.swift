//
//  Input.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/1/24.
//
import Foundation

// Utility for handling file input
struct Input: Identifiable, Hashable {
    let name: String
    let lines: [String]
    let id = UUID()

    static func == (lhs: Input, rhs: Input) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // load all input files for the given day
    // return a dict of name -> lines
    static func load(day: Int, name: String = "input") -> [Input] {
        var inputs: [Input] = []

        do {
            let fm = FileManager.default
            let inputsDir = Bundle.main.path(forResource: "Day \(day)", ofType: "", inDirectory: "Inputs")!
            // get all .dat files, then strip the .dat
            let files = try fm.contentsOfDirectory(atPath: inputsDir)
                .filter { $0.hasSuffix(".dat") }
                .map { String($0.split(separator: ".")[0]) }

            for file in files {
                let filePath = Bundle.main.path(forResource: file, ofType: "dat", inDirectory: "Inputs/Day \(day)")!
                var data = try String(contentsOfFile: filePath, encoding: .utf8)
                data = data.trimmingCharacters(in: .newlines) // remove trailing newlines
                let lines = data.components(separatedBy: .newlines)
                inputs.append(Input(name: file, lines: lines))
            }
        } catch {
            print("Could not load files for day \(day)")
        }
        return inputs.sorted { $0.name < $1.name }
    }
}
