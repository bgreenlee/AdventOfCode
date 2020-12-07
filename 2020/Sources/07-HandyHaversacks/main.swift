import Foundation
import Shared

struct BagSet {
    var num: Int
    var color: String
}

var allBags: Dictionary<String, [BagSet]> = [:]

func descendants(_ color: String) -> [String] {
    if let children = allBags[color] {
        let decs = Set(children.map { $0.color }).union(children.flatMap { descendants($0.color) })
        return Array(decs)
    }
    return []
}

if let input = try Bundle.module.readFile("data/test.dat") {
    let bagsOuterRegex = try! RegEx(pattern: #"^(.*?) bags contain (.*?)\.$"#)
    let bagsInnerRegex = try! RegEx(pattern: #"(\d+|no) (.*?) bag"#)

    let lines = input.components(separatedBy: .newlines)
    for line in lines {
        let matches = bagsOuterRegex.matchGroups(in: line)
        if matches.isEmpty {
            continue
        }
        let color = matches[0][0]
        let childrenString = matches[0][1]
        let childMatches = bagsInnerRegex.matchGroups(in: childrenString)
        for childMatch in childMatches {
            let quantity = childMatch[0]
            let childColor = childMatch[1]

            if quantity == "no" {
                allBags[color] = []
                continue
            }

            let bagSet = BagSet(num: Int(quantity) ?? 0, color: childColor)
            if allBags[color] != nil {
                allBags[color]!.append(bagSet)
            } else {
                allBags[color] = [bagSet]
            }
        }
    }

    let ancestors = allBags.keys.filter { descendants($0).contains("shiny gold") }
    print("Part 1: \(ancestors.count)")
}


