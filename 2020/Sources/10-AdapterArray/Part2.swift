import Foundation
import Shared

struct Part2 {
    /**
     We want to count the number of legal combinations. Our problem is simplified somewhat
     by the observation from part 1 that each number in the sorted list of numbers differs
     from the previous number by either 1 or 3.

     The only time we have more than one option in a set of numbers is when we have a run of
     at least three consecutive numbers. E.g. if we have:

       0 1

     we have only one combination. But if we have:

       0 1 2

     we have two combinations:

       0 1 2
       0 2

     If we have a run of four numbers, we have four combinations:

       0 1 2 3
       0 1 3
       0 2 3
       0 3

     Note that since the first and last numbers are always required, the only numbers that
     matter are the middle, and what we're doing is calculating the power set (set of all subsets,
     which includes the empty set) of those middle numbers, which has a size of 2**n.

     It gets a bit tricky once we have a run of more than four numbers, as some elements of the
     power set will be illegal, having a difference of more than three between numbers. We can
     adjust for this by subtracting the power set of n - 3. So the formula is:

     2**n for n < 3
     2**n - 2**(n-3) for n >= 3

     So that gives us the number of combinations for each run of numbers. All we have to do next
     is return the product of all of these combinations.
     */
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
