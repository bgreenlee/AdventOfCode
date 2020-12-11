import Foundation

struct Part1 {
    static func solve(_ waitingArea: inout WaitingArea) -> Int {
        var lastState = waitingArea.state
        while true {
            waitingArea.cycle(immediate: true, occupiedThreshold: 4)
            let state = waitingArea.state
            if state == lastState {
                break
            }
            lastState = state
        }
        return waitingArea.seats.filter { $0.value == true }.count
    }
}
