import Foundation
import Shared

if let input = try Bundle.module.readFile("data/input.dat") {
    let numbers = input.components(separatedBy: .newlines)
                       .compactMap { Int($0) }


    if let target = Part1.run(preamble: 25, numbers: numbers) {
        print("Part 1: \(target)")
        if let weakness = Part2.run(target: target, numbers: numbers) {
            print("Part2: \(weakness)")
        }
    }
}
