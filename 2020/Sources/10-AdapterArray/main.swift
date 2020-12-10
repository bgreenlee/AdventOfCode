import Foundation
import Shared

if let input = try Bundle.module.readFile("data/input.dat") {
    var numbers = input.components(separatedBy: .newlines)
                       .compactMap { Int($0) }
    numbers.append(0)
    numbers.sort()
    numbers.append(numbers[numbers.count-1] + 3)

    print("Part 1: \(Part1.solve(numbers))")
    print("Part 2: \(Part2.solve(numbers))")
}
