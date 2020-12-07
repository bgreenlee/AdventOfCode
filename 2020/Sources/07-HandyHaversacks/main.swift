import Foundation
import Shared

if let input = try Bundle.module.readFile("data/input.dat") {
    var baggage = Baggage()
    let lines = input.components(separatedBy: .newlines)
    for line in lines {
        baggage.add(line)
    }

    let numAncestors = baggage.ancestors("shiny gold").count
    print("Part 1: \(numAncestors)")

    let containedBags = baggage.containedBags("shiny gold")
    print("Part 2: \(containedBags)")
}
