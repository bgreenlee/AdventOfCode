import sys
from collections import defaultdict

cwd = []
dirs = defaultdict(int)
for line in sys.stdin:
    match line.rstrip().split():
        case ["$", "cd", ".."]:
            cwd.pop()
        case ["$", "cd", dir]:
            cwd.append(dir)
        case [size, _] if size.isnumeric():
            for i in range(len(cwd)):
                dirs[tuple(cwd[:len(cwd)-i])] += int(size)

# part 1
sizes = sorted(dirs.values())
print("Part 1: %d" % sum([s for s in sizes if s <= 100000]))

# part 2
delete_amt = 30000000 - (70000000 - dirs[("/",)])
print("Part 2: %d" % next(s for s in sizes if s > delete_amt))