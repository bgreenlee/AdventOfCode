import Foundation
import Shared

if let input = try Bundle.module.readFile("data/input.dat") {
    let lines = input.components(separatedBy: .newlines)
                       .filter { $0.count > 0 }

    let jigsaw = Jigsaw(lines)
    let corners = jigsaw.findCorners()
    let part1ans = corners.reduce(1,*)
    print("Part 1: \(part1ans)")
}
