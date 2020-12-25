import Foundation
import Shared

//let input = "389125467" // test
let input = "368195742" // prod

var crabCups = CrabCups(input)
crabCups.cycle(100)
print("Part 1: \(crabCups.part1Solution())")

crabCups = CrabCups(input, embiggen: 1000000)
let start = CFAbsoluteTimeGetCurrent()
crabCups.cycle(1000)
print("Part 2: \(crabCups.part2Solution())")
print("\(CFAbsoluteTimeGetCurrent() - start) sec")


