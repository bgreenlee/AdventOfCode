import Foundation

struct CrabCups {
    var labelToIndex:[Int]
    var indexToLabel:[Int]
    var size:Int
    var min:Int
    var max:Int
    var current = 0

    init(_ input:String, embiggen:Int = 0) {
        let cups = input.map {Int(String($0))!}
        size = [cups.count, embiggen].max()!
        labelToIndex = Array(repeating: 0, count: size+1)
        indexToLabel = Array(repeating: 0, count: size+1)

        for (i, cup) in cups.enumerated() {
            labelToIndex[cup] = i
            indexToLabel[i] = cup
        }
        if embiggen > cups.count {
            for i in cups.count..<embiggen {
                labelToIndex[i + 1] = i
                indexToLabel[i] = i + 1
            }
        }
        min = 1 // labelToIndex.keys.min()!
        max = embiggen > cups.count ? embiggen : cups.max()! // labelToIndex.keys.max()!
    }

    func index(_ i:Int) -> Int {
        return i % size
    }

    mutating func store(label:Int, at:Int) {
        labelToIndex[label] = at
        indexToLabel[at] = label
    }

    mutating func cycle(_ n:Int = 1) {
        var start = CFAbsoluteTimeGetCurrent()

        for round in 1...n {
//            render()
            if round % 10000 == 0 {
                print("cycle \(round): \(part2Solution()) (\(CFAbsoluteTimeGetCurrent() - start) sec)")
                start = CFAbsoluteTimeGetCurrent()
            }
            let pick = (1...3).map { indexToLabel[index(current + $0)] }
            let dest = findDestination()
            // move the picked cups to after the destination
            var ptr = index(current + 1)
            while true {
                store(label: indexToLabel[index(ptr + 3)], at: ptr)
                if index(ptr + 3) == dest {
                    break
                }
                ptr = index(ptr + 1)
            }
            (1...3).forEach { store(label: pick[$0 - 1], at: index(ptr + $0)) }
            current = index(current + 1)
        }
    }

    func lower(_ target:Int) -> Int {
        return target - 1 < min ? max : target - 1
    }

    func findDestination() -> Int {
        var targetLabel = lower(indexToLabel[current])
        var destIdx = labelToIndex[targetLabel]

        // if it is one of the cups we picked up, decrease target and try again
        while destIdx == index(current + 1) || destIdx == index(current + 2) || destIdx == index(current + 3) {
            targetLabel = lower(targetLabel)
            destIdx = labelToIndex[targetLabel]
        }
        return destIdx
    }

    func render() {
        for i in 0..<[size, 100].min()! {
            if i == current {
                print("(\(indexToLabel[i])) ", terminator: "")
            } else {
                print("\(indexToLabel[i]) ", terminator: "")
            }
        }
        print()
    }

    func part1Solution() -> String {
        var result = ""
        for i in 1..<size {
            result += String(indexToLabel[(labelToIndex[1] + i) % size])
        }
        return result
    }

    func part2Solution() -> Int {
        let oneIdx = labelToIndex[1]
        return indexToLabel[index(oneIdx+1)] * indexToLabel[index(oneIdx+2)]
    }

}
