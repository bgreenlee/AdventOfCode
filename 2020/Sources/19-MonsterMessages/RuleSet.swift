import Foundation

struct RuleSet {
    var rules: Dictionary<String, String> = [:]
    var matchers: Dictionary<String, Matcher> = [:]

    init(with ruleStrings:[String]) {
        // parse out rule strings
        for ruleString in ruleStrings {
            let parts = ruleString.components(separatedBy: ": ")
            if parts.count == 2 {
                rules[parts[0]] = parts[1]
            }
        }

        // generate matchers
        for (ruleno, rule) in rules {
            matchers[ruleno] = buildMatcher(rule)
        }
    }

    func buildMatcher(_ rule: String) -> Matcher {
        if rule.hasPrefix("\"") && rule.hasSuffix("\"") {
            return LiteralMatcher(rule.trimmingCharacters(in: CharacterSet(charactersIn: "\"")))
        }

        let orParts = rule.components(separatedBy: " | ")
        if orParts.count > 1 {
            return AnyMatcher(orParts.map { buildMatcher($0) })
        }

        let andParts = rule.components(separatedBy: " ")
        return AllMatcher(andParts.map { buildMatcher(rules[$0]!) })
    }
}

protocol Matcher {
    func match(_ str:String) -> (Bool, String)
}

// match a string literal
struct LiteralMatcher: Matcher {
    var literal: String

    init(_ literal:String) {
        self.literal = literal
    }

    func match(_ str: String) -> (Bool, String) {
        if str.starts(with: literal) {
            return (true, String(str.dropFirst(literal.count)))
        }
        return (false, str)
    }
}

// match all of a sequence of matchers
struct AllMatcher: Matcher {
    var matchers: [Matcher]

    init(_ matchers:[Matcher]) {
        self.matchers = matchers
    }

    func match(_ str: String) -> (Bool, String) {
        var remaining = str
        var isMatch: Bool

        for matcher in matchers {
            (isMatch, remaining) = matcher.match(remaining)
            if !isMatch {
                return (false, str)
            }
        }
        return (true, remaining)
    }
}

// match any one of a sequence of matchers
struct AnyMatcher: Matcher {
    var matchers: [Matcher]

    init(_ matchers:[Matcher]) {
        self.matchers = matchers
    }

    func match(_ str: String) -> (Bool, String) {
        var remaining = str
        var isMatch: Bool

        for matcher in matchers {
            (isMatch, remaining) = matcher.match(str)
            if isMatch {
                return (true, remaining)
            }
        }
        return (false, str)
    }
}
