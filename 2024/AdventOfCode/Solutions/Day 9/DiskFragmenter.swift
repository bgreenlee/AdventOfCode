//
//  DiskFragmenter.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/9/24.
//
import Collections

class DiskFragmenter: Solution {
    init() {
        super.init(id: 9, name: "Disk Fragmenter", hasDisplay: true)
    }

    struct Block: CustomStringConvertible {
        var fileId: Int?
        var pos: Int = 0
        var size: Int = 0
        var description: String {
            fileId == nil ? ".(\(pos),\(size))" : "\(fileId!)(\(pos),\(size))"
        }
        var isFree: Bool { fileId == nil }
        var isFile: Bool { fileId != nil }
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
            if memory[i].isFree {
                let lastFileBlockIndex = memory.lastIndex(where: \.isFile)
                if lastFileBlockIndex! < i {
                    break
                }
                memory[i] = memory[lastFileBlockIndex!]
                memory[lastFileBlockIndex!] = Block()
            }
        }

        self.display[.part1] = "\(memory)"
        let checksum = memory.enumerated().reduce(0) { (acc, tuple) in
            let (i, block) = tuple
            return acc + i * (block.fileId ?? 0)
        }
        return String(checksum)
    }

    override func part2(_ input: [String]) -> String {
        let diskmap = parseInput(input)
        var files: [Block] = []
        var freeSpace: [Block] = []
        var pos = 0
        for (i, n) in diskmap.enumerated() {
            if i % 2 == 0 {
                files.append(Block(fileId: i / 2, pos: pos, size: n))
            } else {
                freeSpace.append(Block(pos: pos, size: n))
            }
            pos += n
        }

        for i in (0..<files.count).reversed() {
            for j in 0..<freeSpace.count {
                if files[i].pos < freeSpace[j].pos { break }  // only look at memory to our left
                if files[i].size <= freeSpace[j].size {
                    files[i].pos = freeSpace[j].pos  // "move" file
                    freeSpace[j].size -= files[i].size
                    freeSpace[j].pos += files[i].size
                    break
                }
            }
        }

        self.display[.part2] = "\(files.sorted { $0.pos < $1.pos })"
        let checksum = files.sorted { $0.pos < $1.pos }.reduce(0) { (acc, b) in
            let sum = b.fileId! * (2 * b.pos + b.size - 1) * b.size / 2
            return acc + sum
        }
        return String(checksum)
    }
}
