import Foundation
import Shared

if let input = try Bundle.module.readFile("data/input.dat") {
    let rows = input.components(separatedBy: .newlines)
                       .filter { $0.count > 1 }

    var waitingArea = WaitingArea(rows)
    while waitingArea.cycle(immediate: true, occupiedThreshold: 4) {}
    print("Part 1: \(waitingArea.numOccupied)")

    waitingArea = WaitingArea(rows)
    while waitingArea.cycle(immediate: false, occupiedThreshold: 5) {}
    print("Part 2: \(waitingArea.numOccupied)")
}
