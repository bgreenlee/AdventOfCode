import Foundation

struct Part1 {
    static func solve(_ waitingArea: inout WaitingArea) -> Int {
        while waitingArea.cycle(immediate: true, occupiedThreshold: 4) {}
        return waitingArea.numOccupied
    }
}
