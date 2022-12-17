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


def part1(jets: list[str]) -> int:
    board_width = 7
    board = make_board(board_width, 3)
    rock_i = 0
    jet_i = 0

    while rock_i < 2022:
        # update rock and board
        rock = rocks[rock_i % len(rocks)]
        rock_height = len(rock)
        rock_width = len(rock[0])
        board = expand_board(board, rock_height)
        rx = 2
        ry = len(board) - 1 - highest_rock(board) - 3

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


    return highest_rock(board)

#
# main
#

jets = list(sys.stdin.readline().rstrip())
#jets = list(">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>")
print("Part 1:", part1(jets))
