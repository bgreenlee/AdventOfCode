import Foundation

struct CrabCups {
    var labelToIndex:Dictionary<Int,Int> = Dictionary(minimumCapacity: 1000000)
    var indexToLabel:Dictionary<Int,Int> = Dictionary(minimumCapacity: 1000000)
    var size:Int
    var min:Int
    var max:Int
    var current = 0

    init(_ input:String, embiggen:Int = 0) {
        let cups = input.map {Int(String($0))!}
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
        size = labelToIndex.count
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

    mutating func move(from:Int, to:Int) {
        store(label: indexToLabel[from]!, at: to)
    }

    mutating func cycle(_ n:Int = 1) {
        for round in 1...n {
//            render()
            if round % 100 == 0 {
                print("cycle \(round)")
            }
            let pick = (1...3).map { indexToLabel[index(current + $0)]! }
            let dest = findDestination()
            // move the picked cups to after the destination
            var ptr = index(current + 1)
            while true {
                move(from: index(ptr + 3), to: ptr)
                if index(ptr + 3) == dest {
                    break
                }
                ptr = index(ptr + 1)
            }
            (1...3).forEach { store(label: pick[$0 - 1], at: index(ptr + $0)) } // cups[index(ptr + $0)] = pick[$0 - 1] }
            current = index(current + 1)
        }
    }

    func lower(_ target:Int) -> Int {
        return target - 1 < min ? max : target - 1
    }

    func findDestination() -> Int {
        var targetLabel = lower(indexToLabel[current]!)
        var destIdx = 0
        while true {
            destIdx = labelToIndex[targetLabel]!
            // if it is one of the cups we picked up, decrease target and try again
            if destIdx == index(current + 1) || destIdx == index(current + 2) || destIdx == index(current + 3) {
                targetLabel = lower(targetLabel)
            } else {
                break // found it!
            }
        }
        return destIdx
    }

    func render() {
        for i in 0..<[size, 100].min()! {
            if i == current {
                print("(\(indexToLabel[i]!)) ", terminator: "")
            } else {
                print("\(indexToLabel[i]!) ", terminator: "")
            }
        }
        print()
    }

    func part1Solution() -> String {
        var result = ""
        for i in 1..<size {
            result += String(indexToLabel[(labelToIndex[1]! + i) % size]!)
        }
        return result
    }

    func part2Solution() -> Int {
        let oneIdx = labelToIndex[1]!
        return indexToLabel[index(oneIdx+1)]! * indexToLabel[index(oneIdx+2)]!
    }

}
