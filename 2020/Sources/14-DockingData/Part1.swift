import Foundation
import Shared

struct Part1 {
    static func solve(_ input: [String]) -> UInt {
        let memRegex = try! RegEx(pattern: #"mem\[(\d+)\]"#)

        var memory: Dictionary<UInt, UInt> = [:]
        var mask = ""
        for row in input {
            let parts = row.components(separatedBy: " = ")
            let key = parts[0]
            let value = parts[1]
            if key == "mask" {
                mask = value
            } else {
                let location = UInt(memRegex.matchGroups(in: key)[0][0]) ?? 0
                var memval = UInt(value) ?? 0
                // apply mask
                for (i, char) in mask.enumerated() {
                    if char == "0" {
                        memval &= UInt.max - pow(2, 35-i).uint
                    } else if char == "1" {
                        memval |= UInt(1) << (35-i)
                    }
                }
                memory[location] = memval
            }
        }
        return memory.values.reduce(0, +)
    }
}
