import Foundation

typealias vec = SIMD3<Int>

// Construct a grammar and string match using the CYK algorithm
// Because I'm lazy, assumes the grammar is already in Chomsky Normal Form
struct Grammar {
    var nonterminals: Dictionary<Int, [(Int,Int)]> = [:] // ruleno -> [(rule1,rule2)]
    var terminals: Dictionary<String, [Int]> = [:] // terminal -> [rules]

    init(with ruleStrings:[String]) {
        // parse out rule strings
        for ruleString in ruleStrings {
            let parts = ruleString.components(separatedBy: ": ")
            if parts.count == 2 {
                let options = parts[1].components(separatedBy: " | ")
                let ruleno = Int(parts[0])!
                for option in options {
                    var nonterminalOption: [Int] = []
                    for unit in option.components(separatedBy: " ") {
                        if unit.starts(with: "\"") {
                            let terminal = unit.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                            terminals[terminal, default: []].append(ruleno)
                        } else {
                            nonterminalOption.append(Int(unit)!)
                        }
                    }
                    if !nonterminalOption.isEmpty {
                        nonterminals[ruleno, default: []].append((nonterminalOption[0], nonterminalOption[1]))
                    }
                }
            }
        }
    }

    // match the string to the grammer using the CYK algorithm
    // https://en.wikipedia.org/wiki/CYK_algorithm
    func match(_ message:String) -> Bool {
        let n = message.count
        var P:Dictionary<vec,Bool> = [:]

        // assign terminals
        for s in 1...n {
            for ruleno in terminals[message[s-1]] ?? [] {
                P[vec(1, s, ruleno)] = true
            }
        }

        for len in 2...n {
            for s in 1...n - len + 1 {
                for p in 1...len - 1 {
                    for (ruleno, options) in nonterminals {
                        for (b,c) in options {
                            if P[vec(p, s, b), default: false] && P[vec(len - p, s + p, c), default: false] {
                                P[vec(len, s, ruleno)] = true
                            }
                        }
                    }
                }
            }
        }

        return P[vec(n,1,0), default: false] // 0 on the last dimension because our start rule is 0
    }
}
