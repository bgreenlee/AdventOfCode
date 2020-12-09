import Foundation

struct Part2 {
    static func run(target: Int, numbers: [Int]) -> Int? {
        for runlen in 2..<numbers.count-1 {
            for start in 0..<numbers.count-runlen {
                var sum = 0
                var min = Int.max
                var max = Int.min
                for i in start..<start+runlen {
                    sum += numbers[i]
                    if numbers[i] < min {
                        min = numbers[i]
                    }
                    if numbers[i] > max {
                        max = numbers[i]
                    }
                }
                if sum == target {
                    return min + max
                }
            }
        }
        return nil
    }
}
