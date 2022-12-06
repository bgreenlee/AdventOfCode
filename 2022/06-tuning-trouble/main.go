package main

import (
	"fmt"
	"os"

	"github.com/bgreenlee/AdventOfCode/tree/main/2022/util"
)

func solve(line string, num int) int {
	runes := []rune(line)
	runemap := make(map[rune]int) // map of runes to the last position we saw them
	for i := 0; i < len(runes); i++ {
		if last_i, found := runemap[runes[i]]; found {
			runemap = make(map[rune]int) // clear the map
			i = last_i + 1               // skip ahead of the last dup
		}
		runemap[runes[i]] = i
		if len(runemap) == num {
			return i
		}
	}
	return 0
}

func main() {
	lines, _ := util.ReadLines(os.Stdin)

	fmt.Printf("Part 1: %d\n", solve(lines[0], 4))
	fmt.Printf("Part 2: %d\n", solve(lines[0], 14))
}
