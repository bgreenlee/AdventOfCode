import Foundation

struct Part2 {
    static func run(target: Int, numbers: [Int]) -> Int? {
        for runlen in 2..<numbers.count-1 {
            for start in 0..<numbers.count-runlen {
                let subset = numbers[start..<start+runlen]
                if subset.sum() == target {
                    return subset.min()! + subset.max()!
                }
            }
        }
        return nil
    }
}
