import Foundation
import Shared

if let input = try Bundle.module.readFile("data/input2-cnf.dat") {
    let lines = input.components(separatedBy: .newlines)
                       .filter { $0.count > 0 }

    let grammar = Grammar(with: lines)
    let messages = lines.filter({ !$0.contains(":") })

    var numMatching = 0
    for message in messages {
        print("\(message) -> ", terminator:"")
        let isMatch = grammar.match(message)
        print(isMatch)
        if isMatch {
            numMatching += 1
        }
    }
//    let numMatching = messages.filter { grammar.match($0) }.count
    print("Matching: \(numMatching)")
}
