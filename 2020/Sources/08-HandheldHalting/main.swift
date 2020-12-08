import Foundation
import Shared

if let input = try Bundle.module.readFile("data/input.dat") {
    let lines = input.components(separatedBy: .newlines)

    Part1.run(with: lines)
    Part2.run(with: lines)
}
