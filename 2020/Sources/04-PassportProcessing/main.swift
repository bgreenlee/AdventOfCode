import Foundation

if let inputURL = Bundle.module.url(forResource: "input", withExtension: "dat", subdirectory: "data") {
    let data = try String(contentsOf: inputURL)
    let lines = data.components(separatedBy: .newlines)

    // combine records into single lines
    var records: [String] = []
    var currentRecord = ""
    for line in lines {
        if line != "" {
            currentRecord += line + " "
        } else {
            records.append(currentRecord)
            currentRecord = ""
        }
    }
    if currentRecord.count > 0 {
        records.append(currentRecord)
    }
    
    print("Part 1:")
    Part1.run(with: records)
    print("Part 2:")
    Part2.run(with: records)
}


