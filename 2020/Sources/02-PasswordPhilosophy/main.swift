import Foundation

var input: [String] = []
if let inputURL = Bundle.module.url(forResource: "input", withExtension: "dat") {
    let data = try String(contentsOf: inputURL)
    input = data.components(separatedBy: .newlines)
}

print("Part 1:")
Part1.run(with: input)

print("Part 2:")
Part2.run(with: input)
