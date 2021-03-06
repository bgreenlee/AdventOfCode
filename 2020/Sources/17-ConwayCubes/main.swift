import Foundation
import Shared


if let input = try Bundle.module.readFile("data/input.dat") {
    let rows = input.components(separatedBy: .newlines)
                       .filter { $0.count > 0 }

    var space3d = Space3D(rows)
    space3d.cycle(6)
    print("Part 1: \(space3d.cubes.count)")

    var space4d = Space4D(rows)
    let startTime = CFAbsoluteTimeGetCurrent()
    space4d.cycle(6)
    print("time: \(CFAbsoluteTimeGetCurrent() - startTime)")
    print("Part 2: \(space4d.cubes.count)")


}
