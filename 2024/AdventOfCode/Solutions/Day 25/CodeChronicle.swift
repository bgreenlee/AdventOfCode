//
//  CodeChronicle.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/31/24.
//

class CodeChronicle: Solution {
    init() {
        super.init(id: 25, name: "Code Chronicle", hasDisplay: true)
    }

    override func part1(_ input: [String]) -> String {
        let input = input.joined(separator: "\n").split(separator: "\n\n")

        var locks: Set<SIMD8<Int>> = []
        var keys: Set<SIMD8<Int>> = []
        for block in input {
            let lines = block.split(separator: "\n")
            var heights = SIMD8(0,0,0,0,0,0,0,0)
            for line in lines {
                let nums = line.map { $0 == "#" ? 1 : 0 } + [0,0,0]
                heights &+= SIMD8(nums)
            }
            if lines[0] == "#####" {
                locks.insert(heights)
            } else {
                keys.insert(heights)
            }
        }

        var count = 0
        let max = SIMD8(repeating: 7)
        for lock in locks {
            for key in keys {
                let sum = lock &+ key
                let mask = sum .<= max
                count += mask == SIMDMask(repeating: true) ? 1 : 0
            }
        }

        return String(count)
    }

    override func part2(_ input: [String]) -> String {
        return ""
    }
}
