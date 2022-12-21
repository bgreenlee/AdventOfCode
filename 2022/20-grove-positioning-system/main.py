import sys
from collections import deque


def solve(nums: list[int], decryption_key: int=1, rounds: int=1) -> int:
    # we use enumerate to generate tuples because the acutal input data has duplicate numbers
    # using a tuple makes each one unique
    nums = list(enumerate([n * decryption_key for n in nums]))
    ring = deque(nums)

    for i in range(rounds):
        for n in nums:
            if n[1] == 0:
                continue
            ring.rotate(-ring.index(n))
            ring.rotate(-ring.popleft()[1])
            ring.appendleft(n)

    pos = ring.index([n for n in nums if n[1] == 0][0])
    score = sum(ring[(pos + n) % len(ring)][1] for n in [1000, 2000, 3000])
    return score

#
# main
#
nums = [int(line.rstrip()) for line in sys.stdin]
print("Part 1:", solve(nums))
print("Part 2:", solve(nums, 811589153, 10))
