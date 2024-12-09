//
//  DiskFragmenter.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/9/24.
//

class DiskFragmenter: Solution {
    init() {
        super.init(id: 9, name: "Disk Fragmenter", hasDisplay: true)
    }

    struct Block: CustomStringConvertible {
        var fileId: Int?
        var description: String {
            fileId == nil ? "." : String(fileId!)
        }

        func isFree() -> Bool {
            fileId == nil
        }
    }

    func parseInput(_ input: [String]) -> [Int] {
        Array(input[0]).map { $0.wholeNumberValue! }
    }

    override func part1(_ input: [String]) -> String {
        let diskmap = parseInput(input)
        var memory: [Block] = []
        for (i, n) in diskmap.enumerated() {
            let blocks =
                i % 2 == 0
                ? Array(repeating: Block(fileId: i / 2), count: n)
                : Array(repeating: Block(), count: n)
            memory.append(contentsOf: blocks)
        }

        // compact free space
        // find next free block, then swap that with the last file block
        for i in 0..<memory.count {
            if memory[i].isFree() {
                let lastFileBlockIndex = memory.lastIndex(where: { !$0.isFree() })
                if lastFileBlockIndex! < i {
                    break
                }
                memory[i] = memory[lastFileBlockIndex!]
                memory[lastFileBlockIndex!] = Block()
            }
        }

//        self.display[.part1] = "\(memory)"
        let checksum = memory.enumerated().reduce(0) { (acc, tuple) in
            let (i, block) = tuple
            return block.isFree() ? acc : acc + i * block.fileId!
        }
        return String(checksum)
    }

    override func part2(_ input: [String]) -> String {
        return ""
    }
}
