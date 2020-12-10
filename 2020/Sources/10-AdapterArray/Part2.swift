import Foundation
import Shared

struct Part2 {
    static func solve(_ numbers: [Int]) -> Int {
        var runs: [Int] = []
        var curRun = 0
        for i in 1..<numbers.count {
            if numbers[i] - numbers[i-1] == 1 {
                curRun += 1
            } else if curRun > 0 {
                runs.append(curRun - 1)
                curRun = 0
            }
        }
        let combos = runs.map { pow(2, $0).int - ($0 >= 3 ? pow(2, $0 - 3).int : 0) }
        return combos.reduce(1, *)
    }
}
