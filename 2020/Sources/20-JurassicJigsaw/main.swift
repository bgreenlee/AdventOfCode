import Foundation
import Shared

if let input = try Bundle.module.readFile("data/input.dat") {
    let lines = input.components(separatedBy: .newlines)
                       .filter { $0.count > 0 }

    let jigsaw = Jigsaw(lines)
    let corners = jigsaw.findCorners()
    let part1 = corners.reduce(1,*)
    print("Part 1: \(part1)")

    var image = jigsaw.assemble()
    var numSeadragons = 0
    while true {
        numSeadragons = Jigsaw.findSeadragons(in: image)
        if numSeadragons > 0 {
            break
        }
        image = Jigsaw.rotate(image: image)
    }

    print("Found \(numSeadragons) seadragons")
    let roughness = image.flatMap({$0}).filter({$0 == "#"}).count - numSeadragons * 15
    print("Roughness: \(roughness)")
}
