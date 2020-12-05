import Foundation

if let inputURL = Bundle.module.url(forResource: "input", withExtension: "dat", subdirectory: "data") {
    let input = try String(contentsOf: inputURL)
    let boardingPassIds:[Int] = input.components(separatedBy: .newlines)
        .compactMap {
            let binary = $0.replacingOccurrences(of: "F", with: "0")
                           .replacingOccurrences(of: "B", with: "1")
                           .replacingOccurrences(of: "L", with: "0")
                           .replacingOccurrences(of: "R", with: "1")
            return Int(binary, radix: 2)
        }
        .sorted()

    // Part 1: find the highest id
    print("Part 1: \(boardingPassIds.last!)")
    
    // Part 2: find the first non-consecutive id
    let idealSum = (boardingPassIds.count + 1) * (boardingPassIds.first! + boardingPassIds.last!) / 2
    let actualSum = boardingPassIds.reduce(0, +)
    print("Part 2: \(idealSum - actualSum)")
}
