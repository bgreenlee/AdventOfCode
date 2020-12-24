import Foundation
import Shared

if let input = try Bundle.module.readFile("data/input.dat") {
    let lines = input.components(separatedBy: .newlines)
                       .filter { $0.count > 0 }

    let combat = Combat(lines)
    print("Part 1: \(combat.play())")
    print("Part 2: \(combat.playRecursive())")
}
