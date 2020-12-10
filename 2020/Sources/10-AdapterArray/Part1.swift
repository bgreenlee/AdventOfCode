import Foundation

struct Part1 {
    static func solve(_ numbers: [Int]) -> Int {
        var diffs = [1:0,3:0]
        for i in 1..<numbers.count {
            diffs[numbers[i] - numbers[i-1], default: 0] += 1
        }
        return diffs[1]! * diffs[3]!
    }
}
