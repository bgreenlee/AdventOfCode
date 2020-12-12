import Foundation
import Shared

if let input = try Bundle.module.readFile("data/input.dat") {
    let rows = input.components(separatedBy: .newlines)
                       .filter { $0.count > 1 }

    print("Part 1: \(Part1.solve(rows))")
    print("Part 2: \(Part2.solve(rows))")
}
