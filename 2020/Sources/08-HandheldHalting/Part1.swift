import Foundation

struct Part1 {
    static func run(with lines: [String]) {
        var executed: Set<Int> = []
        var lineno = 0
        var accumulator = 0

        while true {
            if executed.contains(lineno) {
                break // we hit a loop
            }
            executed.update(with: lineno)

            let parts = lines[lineno].split(separator: " ")
            let oper = parts[0]
            let value = Int(parts[1]) ?? 0

            switch oper {
            case "acc":
                accumulator += value
                lineno += 1
            case "jmp":
                lineno += value
            default: // nop
                lineno += 1
            }
        }

        print("Part 1: \(accumulator)")
    }
}
