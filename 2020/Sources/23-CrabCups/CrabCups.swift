import Foundation

struct CrabCups {
    var cups:[Int]
    var min:Int
    var max:Int
    var current:Int

    init(_ input:String, embiggen:Int = 0) {
        let inputCups = input.map {Int(String($0))!}

        // create "linked list" array where the value of each index
        // is the next cup label clockwise
        let size = [inputCups.count, embiggen].max()!
        cups = Array(repeating: 0, count: size+1)
        for i in 0..<inputCups.count-1 {
            cups[inputCups[i]] = inputCups[i+1]
        }
        cups[inputCups.last!] = inputCups.first! // link the end back to the beginning

        if embiggen > inputCups.count {
            cups[inputCups.last!] = inputCups.count + 1
            for i in inputCups.count + 1..<embiggen {
                cups[i] = i + 1
            }
            cups[embiggen] = inputCups.first!
        }

        min = 1
        max = embiggen > inputCups.count ? embiggen : inputCups.max()!
        current = inputCups[0]
    }

    mutating func cycle(_ n:Int = 1) {
        for _ in 1...n {
            // pick the next three cups
            let pick = [cups[current], cups[cups[current]], cups[cups[cups[current]]]]

            // find destination cup
            // if it is one of the cups we picked up, decrease target and try again
            var dest = current - 1 < min ? max : current - 1
            while pick.contains(dest) {
                dest = dest - 1 < min ? max : dest - 1
            }

            // move the picked cups to after the destination
            cups[current] = cups[pick[2]]
            cups[pick[2]] = cups[dest]
            cups[dest] = pick[0]
            cups[pick[0]] = pick[1]
            cups[pick[1]] = pick[2]

            current = cups[current] // move pointer
        }
    }

    func part1Solution() -> String {
        var i = 1
        var result = String(cups[i])
        i = cups[i]
        while cups[i] != 1 {
            result += String(cups[i])
            i = cups[i]
        }
        return result
    }

    func part2Solution() -> Int {
        return cups[1] * cups[cups[1]]
    }
}
