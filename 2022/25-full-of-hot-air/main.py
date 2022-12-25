import sys

snafu_digits = { '2': 2, '1': 1, '0': 0, '-': -1, '=': -2 }

def snafu_to_decimal(num: str) -> int:
    return sum(snafu_digits[num[-i-1]] * 5**i for i in range(len(num)))

def decimal_to_snafu(num: int) -> str:
    result = ""
    while num:
        digit = num % 5
        if digit > 2:
            result += "=-"[digit - 3]
            num += (5 - digit)
        else:
            result += str(digit)
        num //= 5
    return result[::-1] or "0"

lines = sys.stdin.read().splitlines()
print("Part 1:", decimal_to_snafu(sum(snafu_to_decimal(line) for line in lines)))