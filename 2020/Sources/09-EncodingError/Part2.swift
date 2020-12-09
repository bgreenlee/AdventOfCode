import Foundation

struct Part2 {
    static func solve(target: Int, numbers: [Int]) -> Int {
        var low = 0
        var high = 0
        var sum = 0
        while sum != target {
            if sum > target {
                sum -= numbers[low]
                low += 1
            } else {
                sum += numbers[high]
                high += 1
            }
        }
        return numbers[low...high].min()! + numbers[low...high].max()!
    }
}
