import sys

def part1(forest: list[list[int]]) -> int:
    size = len(forest[0])
    # array of maxes from each direction (E, W, N, S)
    maxes = [[[0,0,0,0] for x in range(size)] for y in range(size)]

    for y in range(1, size-1):
        # calculate maxes from east
        for x in range(1, size-1):
            maxes[y][x][0] = max(maxes[y][x-1][0], forest[y][x-1])

        # calculate maxes from west
        for x in range(size-2, 0, -1):
            maxes[y][x][1] = max(maxes[y][x+1][1], forest[y][x+1])

    for x in range(size):
        # calculate maxes from north
        for y in range(1, size-1):
            maxes[y][x][2] = max(maxes[y-1][x][2], forest[y-1][x])

        # calculate maxes from south
        for y in range(size-2, 0, -1):
            maxes[y][x][3] = max(maxes[y+1][x][3], forest[y+1][x])

    # visible trees are those that are greater than the max from any direction
    visible = (size-1)*4 # edges
    for y in range(1,size-1):
        for x in range(1,size-1):
            if forest[y][x] > min(maxes[y][x]):
                visible += 1

    return visible

def part2(forest: list[list[int]]) -> int:
    size = len(forest[0])
    max_score = 0
    for y in range(size):
        for x in range(size):
            # number of trees visible in each direction
            east, west, north, south = 0, 0, 0, 0
            # east
            for i in range(x-1, -1, -1):
                east += 1
                if forest[y][i] >= forest[y][x]:
                    break
            # west
            for i in range(x+1, size):
                west += 1
                if forest[y][i] >= forest[y][x]:
                    break
            # north
            for i in range(y-1, -1, -1):
                north += 1
                if forest[i][x] >= forest[y][x]:
                    break
            # count south
            for i in range(y+1, size):
                if forest[i][x] >= forest[y][x]:
                    break
                south += 1
            max_score = max(max_score, east * west * north * south)

    return max_score


if __name__ == '__main__':
    forest = [[int(n) for n in [*line.rstrip()]] for line in sys.stdin]
    print("Part 1: %d" % part1(forest))
    print("Part 2: %d" % part2(forest))
