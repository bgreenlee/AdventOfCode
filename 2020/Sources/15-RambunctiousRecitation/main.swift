import Foundation
import Shared

let input = "2,15,0,9,1,20"
let startingNumbers = input.components(separatedBy: ",").map { Int($0) ?? 0 }

print("Part 1: \(findNumber(2020))")
print("Part 2: \(findNumber(30000000))")

func findNumber(_ n:Int) -> Int {
    var history:Dictionary<Int, Int> = Dictionary(minimumCapacity: Int(Float(n)*0.15))

    for i in 0..<startingNumbers.count-1 {
        history[startingNumbers[i]] = i
    }

    var lastNumber = startingNumbers[startingNumbers.count-1]

    for i in startingNumbers.count..<n {
        if let lastSeen = history[lastNumber] {
            history[lastNumber] = i - 1
            lastNumber = i - lastSeen - 1
        } else {
            history[lastNumber] = i - 1
            lastNumber = 0
        }
    }

    return lastNumber
}
