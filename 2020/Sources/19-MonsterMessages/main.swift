import Foundation
import Shared

if let input = try Bundle.module.readFile("data/input.dat") {
    let lines = input.components(separatedBy: .newlines)
                       .filter { $0.count > 0 }

    let ruleset = RuleSet(with: lines)
    let messages = lines.filter({ !$0.contains(":") })

    let matcher = ruleset.matchers["0"]!
    let numMatching = messages.filter { message in
        let (isMatch, remaining) = matcher.match(message)
        return isMatch && remaining.isEmpty
    }.count
    print("Part 1: \(numMatching)")
}
