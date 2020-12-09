import Foundation

struct Part1 {
    static func run(preamble: Int, numbers: [Int]) -> Int? {
        var sums: Dictionary<Int,Int> = [:]

        // populate sums with initial preamble
        for i in 0..<preamble-1 {
            for j in i+1..<preamble {
                sums[numbers[i] + numbers[j], default:0] += 1
            }
        }

        for pos in preamble..<numbers.count {
            if sums[numbers[pos]] == nil  || sums[numbers[pos]] == 0 {
                return numbers[pos]
            }
            // advance preamble
            for i in pos-preamble+1..<pos {
                // remove earliest value from sums
                if let target = sums[numbers[pos-preamble] + numbers[i]], target > 0 {
                    sums[numbers[pos-preamble] + numbers[i]] = target - 1
                }
                // add new value to sums
                sums[numbers[pos] + numbers[i], default: 0] += 1
            }
        }
        return nil
    }
}
