import Foundation

// Construct a grammar and string match using the CYK algorithm
// Because I'm lazy, assumes the grammar is already in Chomsky Normal Form
struct Grammar {
    var rules: Dictionary<String, [[String]]> = [:]
    var terminalToRules: Dictionary<String, [String]> = [:]

    init(with ruleStrings:[String]) {
        // parse out rule strings
        for ruleString in ruleStrings {
            let parts = ruleString.components(separatedBy: ": ")
            if parts.count == 2 {
                let options = parts[1].components(separatedBy: " | ")
                rules[parts[0]] = options.map {
                    $0.components(separatedBy: " ")
                      .map { $0.trimmingCharacters(in: CharacterSet.punctuationCharacters) }
                }
            }
        }
        // create a lookup table for our terminals
        for (ruleno, rule) in rules {
            for subrule in rule {
                if subrule[0] >= "a" && subrule[0] <= "z" {
                    terminalToRules[subrule[0], default:[]].append(ruleno)
                }
            }
        }
    }

    // match the string to the grammer using the CYK algorithm
    // https://en.wikipedia.org/wiki/CYK_algorithm
    func match(_ message:String) -> Bool {
        let n = message.count
        let r = rules.keys.map({Int($0)!}).max()!
        var P:[[[Bool]]] = Array(repeating: Array(repeating: Array(repeating: false, count: r + 1), count: n + 1), count: n + 1)

        // for each s = 1 to n
        //     for each unit production Rv → as
        //         set P[1,s,v] = true
        for s in 1...n {
            for rule in terminalToRules[message[s-1]] ?? [] {
                let v = Int(rule)!
                P[1][s][v] = true
            }
        }

        // for each l = 2 to n -- Length of span
        //     for each s = 1 to n-l+1 -- Start of span
        //         for each p = 1 to l-1 -- Partition of span
        //             for each production Ra    → Rb Rc
        //                 if P[p,s,b] and P[l-p,s+p,c] then set P[l,s,a] = true
        for l in 2...n {
            for s in 1...n-l+1 {
                for p in 1...l-1 {
                    for (ruleno, rule) in rules {
                        for subrule in rule {
                            if subrule.count > 1 { // non-terminal
                                let a = Int(ruleno)!
                                let b = Int(subrule[0])!
                                let c = Int(subrule[1])!
                                if P[p][s][b] && P[l-p][s+p][c] {
                                    P[l][s][a] = true
                                }
                            }
                        }
                    }
                }
            }
        }

        // if P[n,1,1] is true then
        //     I is member of language
        // else
        //     I is not member of language
        return P[n][1][0] // 0 on the last dimension because our start rule is 0
    }
}
