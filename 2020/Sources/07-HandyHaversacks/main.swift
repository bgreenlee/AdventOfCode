import Foundation
import Shared

if let input = try Bundle.module.readFile("data/input.dat") {
    var allBags: Set<Bag> = []

    let bagsOuterRegex = try! RegEx(pattern: #"^(.*?) bags contain (.*?)\.$"#)
    let bagsInnerRegex = try! RegEx(pattern: #"(\d+|no) (.*?) bag"#)

    let lines = input.components(separatedBy: .newlines)
    for line in lines {
        let matches = bagsOuterRegex.matchGroups(in: line)
        if matches.isEmpty {
            continue
        }
        let color = matches[0][0]
        let children = matches[0][1]
        var (_, parent) = allBags.insert(Bag(color))
        let childMatches = bagsInnerRegex.matchGroups(in: children)
        for childMatch in childMatches {
            let quantity = childMatch[0]
            let color = childMatch[1]

            if quantity == "no" {
                continue
            }

            var (_, child) = allBags.insert(Bag(color))
            child.parents.update(with: parent)
            parent.children.update(with: child)
            allBags.update(with: child)
            allBags.update(with: parent)
        }
    }

    if let targetBag = allBags.first(where: {$0 == Bag("shiny gold")}) {
//        print(targetBag)
        print(targetBag.ancestors.map { $0.color })
    }
}


