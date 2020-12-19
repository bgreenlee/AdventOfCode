import Foundation

struct Calculator {
    enum Precedence {
        case Left
        case Plus
    }

    static func tokenize(_ equation: String) -> [Token] {
        var tokenized: [Token] = []
        for char in equation {
            switch char {
            case "0"..."9":
                tokenized.append(NumberToken(char.wholeNumberValue!))
            case "+","*":
                tokenized.append(OperatorToken(char))
            case "(":
                tokenized.append(LeftParenToken())
            case ")":
                tokenized.append(RightParenToken())
            default:
                continue
            }
        }
        return tokenized
    }

    // convert infix tokens to postfix using the Shunting Yard algorithm
    static func postfix(_ tokens: [Token], precedence: Precedence = .Left) -> [Token] {
        var outputQueue:[Token] = []
        var operatorStack:[Token] = []

        for token in tokens {
            switch token {
            case is NumberToken:
                outputQueue.append(token)
            case let token as OperatorToken:
                // we're ignoring normal precedence rules, so anything already on the stack except Left Paren has higher precedence
                while let op = operatorStack.last {
                    if op is LeftParenToken || precedence == .Plus && token.op == "+" && (op as! OperatorToken).op == "*" {
                        break
                    }
                    outputQueue.append(operatorStack.popLast()!)
                }
                operatorStack.append(token)
            case is LeftParenToken:
                operatorStack.append(token)
            case is RightParenToken:
                while let op = operatorStack.popLast() {
                    if op is LeftParenToken {
                        break
                    }
                    outputQueue.append(op)
                }
            default:
                print("Unknown token: \(token)")
            }
        }

        while let op = operatorStack.popLast() {
            outputQueue.append(op)
        }

        return outputQueue
    }

    // given a stack of tokens in postfix order, calculate the result
    static func calculate(_ tokens: [Token]) -> Int {
        var calcStack: [Token] = []

        for token in tokens {
            if token is NumberToken {
                calcStack.append(token)
            } else {
                let a = calcStack.popLast()! as! NumberToken
                let b = calcStack.popLast()! as! NumberToken
                if (token as! OperatorToken).op == "+" {
                    calcStack.append(a + b)
                } else {
                    calcStack.append(a * b)
                }
            }
        }

        let result = calcStack.first! as! NumberToken
        return result.value
    }

    static func solve(_ equation: String, precedence: Precedence = .Left) -> Int {
        let tokens = tokenize(equation)
        let postfixTokens = postfix(tokens, precedence: precedence)
        return calculate(postfixTokens)
    }
}
