import Foundation
import Shared

struct Part2 {
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
                var location = UInt(memRegex.matchGroups(in: key)[0][0]) ?? 0
                let memval = UInt(value) ?? 0
                var floatingBits:[Int] = []
                for (i, char) in mask.enumerated() {
                    switch char {
                    case "1":
                        location |= UInt(1) << (35-i)
                    case "X":
                        floatingBits.append(i)
                    default:
                        continue
                    }
                }
                var locations:[UInt] = []
                for i in floatingBits {
                    if locations.isEmpty {
                        locations.append(location & (UInt.max - pow(2, 35-i).uint)) // 0
                        locations.append(location | (UInt(1) << (35-i))) // 1
                    } else {
                        var newLocations:[UInt] = []
                        for loc in locations {
                            newLocations.append(loc & (UInt.max - pow(2, 35-i).uint))
                            newLocations.append(loc | (UInt(1) << (35-i)))
                        }
                        locations = newLocations
                    }
                }
                for loc in locations {
                    memory[loc] = memval
                }
            }
        }
        return memory.values.reduce(0, +)
    }
}
