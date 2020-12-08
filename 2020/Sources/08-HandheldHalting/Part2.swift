import Foundation

struct Part2 {
    static func run(with lines: [String]) {
        var executed: Set<Int> = []
        var lineno = 0
        var accumulator = 0
        var nopjmpTarget = 0
        var nopjmpCounter = 0
        while true {
            if executed.contains(lineno) {
                // we hit a loop, so start over and plan to flip the next nop/jmp statement
                executed.removeAll(keepingCapacity: true)
                lineno = 0
                accumulator = 0
                nopjmpTarget += 1
                nopjmpCounter = 0
            }

            if lineno >= lines.count {
                break
            }

            executed.update(with: lineno)

            let parts = lines[lineno].split(separator: " ")
            if parts.count != 2 {
                lineno += 1
                continue
            }

            let oper = parts[0]
            let value = Int(parts[1]) ?? 0
            switch oper {
            case "nop":
                // treat as a jmp if this is our target
                lineno += nopjmpCounter == nopjmpTarget ? value : 1
                nopjmpCounter += 1
            case "acc":
                accumulator += value
                lineno += 1
            case "jmp":
                // treat as a nop if this is our target
                lineno += nopjmpCounter == nopjmpTarget ? 1 : value
                nopjmpCounter += 1
            default:
                lineno += 1
            }
        }

        print("Part 2: \(accumulator)")
    }
}
