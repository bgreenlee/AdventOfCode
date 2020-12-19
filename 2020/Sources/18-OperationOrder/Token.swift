import Foundation

protocol Token {}

struct NumberToken: Token {
    var value:Int
    init(_ value: Int) {
        self.value = value
    }

    static func +(l: Self, r: Self) -> Self {
        return NumberToken(l.value + r.value)
    }

    static func *(l: Self, r: Self) -> Self {
        return NumberToken(l.value * r.value)
    }
}

struct OperatorToken: Token {
    var op: Character
    init(_ op: Character) {
        self.op = op
    }
}

struct LeftParenToken: Token {}

struct RightParenToken: Token {}
