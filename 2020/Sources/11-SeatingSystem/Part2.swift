import Foundation

struct Part2 {
    static func solve(_ waitingArea: inout WaitingArea) -> Int {
        while waitingArea.cycle(immediate: false, occupiedThreshold: 5) {}
        return waitingArea.numOccupied
    }
}
