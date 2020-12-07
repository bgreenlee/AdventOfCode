import Foundation
import Shared

struct Baggage {
    struct BagSet {
        var num: Int
        var color: String
    }
    var bags: Dictionary<String, [BagSet]> = [:]
    let bagsOuterRegex = try! RegEx(pattern: #"^(.*?) bags contain (.*?)\.$"#)
    let bagsInnerRegex = try! RegEx(pattern: #"(\d+|no) (.*?) bag"#)

    mutating func add(_ line: String) {
        let matches = bagsOuterRegex.matchGroups(in: line)
        if matches.isEmpty {
            return
        }
        let color = matches[0][0]
        let childrenString = matches[0][1]
        let childMatches = bagsInnerRegex.matchGroups(in: childrenString)
        for childMatch in childMatches {
            let quantity = childMatch[0]
            let childColor = childMatch[1]

            if quantity == "no" {
                bags[color] = []
                continue
            }

            let bagSet = BagSet(num: Int(quantity) ?? 0, color: childColor)
            if bags[color] != nil {
                bags[color]!.append(bagSet)
            } else {
                bags[color] = [bagSet]
            }
        }
    }
    
    func descendants(_ color: String) -> Set<String> {
        if let children = bags[color] {
            return Set(children.map { $0.color }).union(children.flatMap { descendants($0.color) })
        }
        return []
    }

    func ancestors(_ color: String) -> [String] {
        return bags.keys.filter { descendants($0).contains(color) }
    }
    
    func containedBags(_ color: String) -> Int {
        if let children = bags[color] {
            return children.map { $0.num * (1 + containedBags($0.color ))}.reduce(0, +)
        }
        return 0
    }
}

