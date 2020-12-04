import Foundation

if let inputURL = Bundle.module.url(forResource: "input", withExtension: "dat", subdirectory: "data") {
    let data = try String(contentsOf: inputURL)
    let map = Map(data: data)
    
    print("Part 1:")
    Part1.run(map: map)
    
    print("Part 2:")
    Part2.run(map: map)
}


