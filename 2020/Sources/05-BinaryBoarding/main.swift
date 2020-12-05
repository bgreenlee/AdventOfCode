import Foundation

if let inputURL = Bundle.module.url(forResource: "input", withExtension: "dat", subdirectory: "data") {
    let input = try String(contentsOf: inputURL)
    let boardingPasses = input.components(separatedBy: .newlines)
                            .compactMap { BoardingPass($0) }
                            .sorted()

    // Part 1: find the highest id
    print("Part 1: \(boardingPasses.last!)")
    
    // Part 2: find the first non-consecutive id
    for i in 1..<boardingPasses.count {
        if boardingPasses[i].id != boardingPasses[i-1].id + 1 {
            print("Part 2: \(boardingPasses[i].id - 1)")
            break
        }
    }
}
