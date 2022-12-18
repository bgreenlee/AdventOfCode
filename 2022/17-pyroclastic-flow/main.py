import sys

rocks = [
    [[1,1,1,1]],

    [[0,1,0],
     [1,1,1],
     [0,1,0]],

    [[0,0,1],
     [0,0,1],
     [1,1,1]],

     [[1],
      [1],
      [1],
      [1]],

     [[1,1],
      [1,1]]
]

Board = list[list[int]]
Rock = list[list[int]]

def highest_rock(board: Board) -> int:
    for y in range(len(board)):
        if any(board[y]):
            return len(board) - y
    return 0


def make_board(width: int, height: int) -> Board:
    return [[0] * width for _ in range(height)]


def expand_board(board: Board, units: int) -> Board:
    new_units = make_board(7, units)
    new_units.extend(board)
    return new_units


def trim_board(board: Board, cutoff_count: int) -> tuple[Board, int]:
    sweeper = [0] * 7
    for i, row in enumerate(board):
        for j in range(7):
            sweeper[j] |= row[j]
            if all(sweeper):
                cutoff_count += len(board) - i - 1
                print("cutoff:", cutoff_count)
                return board[:i+1], cutoff_count
    return board, cutoff_count


def detect_collision(board: Board, rock: Rock, rx, ry) -> bool:
    for y in range(len(rock)-1, -1, -1): # scan from bottom up
        for x in range(len(rock[y])):
            by = ry - (len(rock) - y - 1)
            if by >= len(board) or rock[y][x] & board[by][rx + x]:
                return True
    return False


def place_rock(board: Board, rock: Rock, rx, ry):
    for y in range(len(rock)):
        for x in range(len(rock[y])):
            by = ry - len(rock) + y + 1
            board[by][rx + x] |= rock[y][x]


def solve(jets: list[str], iterations: int) -> int:
    board_width = 7
    board = make_board(board_width, 3)
    rock_i = 0
    jet_i = 0
    cutoff_count = 0

    while rock_i < iterations:
        # update rock and board
        rock = rocks[rock_i % len(rocks)]
        rock_height = len(rock)
        rock_width = len(rock[0])
        highpoint = highest_rock(board)
        if len(board) - highpoint < len(rock) + 3:
            board = expand_board(board, rock_height)
        # board, cutoff_count = trim_board(board, cutoff_count)
        rx = 2
        # print("extra space:", len(board) - highpoint)
        ry = len(board) - 1 - highpoint - 3


        # drop the rock
        while True:
            # apply the jets
            new_rx = max(0, rx - 1) if jets[jet_i % len(jets)] == '<' else min(board_width - rock_width, rx + 1)
            if not detect_collision(board, rock, new_rx, ry):
                rx = new_rx
            jet_i += 1

            # see if we can move the rock down
            if detect_collision(board, rock, rx, ry + 1):
                place_rock(board, rock, rx, ry)
                break
            else:
                ry += 1

        rock_i += 1

    return highest_rock(board) + cutoff_count


def part2(jets: list[str]) -> int:
    iterations = 1000000000000
    diffs = []
    last_result = 0
    i = 0
    max_seq = 0
    cycle = []
    min_cycle_len = len(rocks) * 2

    def max_repeating_sequence(seq):
        max_seq = 1
        start_pos = 0
        max_len = int(len(seq) / 2)
        for l in range(2, max_len):
            for i in range(0, len(seq) - l * 2):
                if seq[i:i+l] == seq[i+l:i+l*2] :
                    max_seq = l
                    start_pos = i
        return max_seq, start_pos

    while True:
        i += 1
        result = solve(jets, i)
        print(i, result)
        diffs.append(result - last_result)
        last_result = result
        if len(diffs) > len(jets):
            max_seq, start_pos = max_repeating_sequence(diffs)
            # print(f"max seq {max_seq} at {start_pos}")
            if max_seq >= min_cycle_len:
                print(f"{i}: cycle of length {max_seq} at start_pos = {start_pos} (len={len(diffs)}); last result = {last_result}")
                # print(diffs[start_pos:start_pos+max_seq])
                # print(diffs[start_pos+max_seq:start_pos+max_seq*2])
                cycle = diffs[start_pos:start_pos+max_seq]
                print("cycle:", cycle)
                print("cycle sum:", sum(cycle))
                break

    full_cycles = int((iterations - i) / max_seq)
    print("full cycles:", full_cycles)
    remainder = (iterations - i) % max_seq
    print("remainder:", remainder)
    total = last_result + full_cycles * sum(cycle) + sum(cycle[:remainder])

    return total
#
# main
#

jets = list(sys.stdin.readline().rstrip())
#jets = list(">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>")
print("Part 1:", solve(jets, 2022))
print("Part 2:", part2(jets))
