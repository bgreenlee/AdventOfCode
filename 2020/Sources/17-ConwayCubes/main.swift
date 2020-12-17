import Foundation
import Shared


if let input = try Bundle.module.readFile("data/input.dat") {
    let rows = input.components(separatedBy: .newlines)
                       .filter { $0.count > 0 }

    var space3d = Space3D(rows)
    for _ in 1...6 {
        space3d.cycle()
    }
    print("Part 1: \(space3d.cubes.count)")

    var space4d = Space4D(rows)
    for _ in 1...6 {
        space4d.cycle()
    }
    print("Part 2: \(space4d.cubes.count)")


}
