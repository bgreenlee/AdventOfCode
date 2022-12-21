import sys
from collections import deque


def solve(nums: list[int], decryption_key: int=1, rounds: int=1) -> int:
    # we use enumerate to generate tuples because the acutal input data has duplicate numbers
    # using a tuple makes each one unique
    num_tuples = list(enumerate([n * decryption_key for n in nums]))
    ring = deque(num_tuples)

    for i in range(rounds):
        for n in num_tuples:
            ring.rotate(-ring.index(n)) # find the number and rotate to it
            ring.rotate(-ring.popleft()[1]) # pop it off and rotate that amount
            ring.appendleft(n) # insert it back in

    pos = ring.index(next(n for n in num_tuples if n[1] == 0)) # find the 0 tuple
    return sum(ring[(pos + n) % len(ring)][1] for n in [1000, 2000, 3000])

#
# main
#r
nums = [int(line.rstrip()) for line in sys.stdin]
print("Part 1:", solve(nums))
print("Part 2:", solve(nums, 811589153, 10))
