import Foundation
import Shared


if let input = try Bundle.module.readFile("data/test.dat") {
    let rows = input.components(separatedBy: .newlines)
                       .filter { $0.count > 0 }

    var space = Space(dimensions: 3, rows: rows)
    for _ in 1...6 {
        space.cycle()
    }
    print("Part 1: \(space.cubes.count)")

    space = Space(dimensions: 4, rows: rows)
    for _ in 1...6 {
        space.cycle()
    }
    print("Part 2: \(space.cubes.count)")
}
