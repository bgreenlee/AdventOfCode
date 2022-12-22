import sys
from pprint import pp 
from sympy import solveset, Eq, symbols
from sympy.parsing.sympy_parser import parse_expr


# expand root
def expand(var: str, lookup: dict) -> list[str]:
    tokens = []
    for token in lookup[var]:
        if token in lookup:
            tokens.extend(expand(token, lookup))
        else:
            tokens.append(token)

    return tokens


def infix_to_postfix(tokens: list[str]) -> list[str]:
    # convert to postfix
    postfix = []
    stack = []
    for token in tokens:
        match token:
            case '(':
                stack.append(token)
            case ')':
                while (tok := stack.pop()) != '(':
                    postfix.append(tok)
            case '*' | '/' | '+' | '-':
                # ignoring precedence because everything is wrapped in parens
                stack.append(token)
            case _:
                postfix.append(token)

    return postfix


# evaluate the given infix expression
def evaluate(infix: list[str|int]) -> str:
    postfix = infix_to_postfix(infix)
    stack = []
    for tok in postfix:
        match tok:
            case "humn":
                stack.append(tok)
            case tok if tok.isnumeric():
                stack.append(tok)
            case _:
                op2 = stack.pop()
                op1 = stack.pop()
                expr = f"({op1} {tok} {op2})"
                if "humn" in expr:
                    stack.append(expr)
                else:
                    stack.append(eval(expr))

    return str(stack[0])


def part1(lookup: dict) -> int:
    return int(float(evaluate(expand('root', lookup))))


def part2(lookup: dict) -> int:
    del lookup["humn"]
    lhs = evaluate(expand(lookup["root"][1], lookup))
    rhs = evaluate(expand(lookup["root"][3], lookup))
    if "humn" in rhs:
        lhs, rhs = rhs, lhs

    expr = Eq(parse_expr(lhs), int(float(rhs)))
    solve = solveset(expr, symbols('humn'))
    return int(list(solve)[0])


#
# main
#
lines = [line.rstrip() for line in sys.stdin]
# build symbol lookup dict
lookup = dict[str, list[str]]()
for line in lines:
    tokens = [sym.rstrip(":") for sym in line.split()]
    # add equals and parens
    tokens.insert(1, "=")
    if len(tokens) > 3:
        tokens.insert(2, "(")
        tokens.append(")")
    lookup[tokens[0]] = tokens[2:]

print("Part 1:", part1(lookup))
print("Part 2:", part2(lookup))