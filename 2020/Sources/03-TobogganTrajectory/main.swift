import Foundation

if let inputURL = Bundle.module.url(forResource: "input", withExtension: "dat") {
    let data = try String(contentsOf: inputURL)
    let map = Map(data: data)
    
    Part1.run(map: map)
}


