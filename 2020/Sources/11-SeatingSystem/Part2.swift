import Foundation

struct Part2 {
    static func solve(_ waitingArea: inout WaitingArea) -> Int {
        var lastState = waitingArea.state
        while true {
            waitingArea.cycle(immediate: false, occupiedThreshold: 5)
            let state = waitingArea.state
            if state == lastState {
                break
            }
            lastState = state
        }
        return waitingArea.seats.filter { $0.value == true }.count
    }
}
