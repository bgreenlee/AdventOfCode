package main

import (
	"fmt"
	"os"

	"github.com/bgreenlee/AdventOfCode/tree/main/2022/util"
)

func calculateScore(lines []string, lookup []int) int {
	score := 0
	for _, line := range lines {
		runes := []rune(line)
		idx := 3*(int(runes[0])-int('A')) + int(runes[2]) - int('X')
		score += lookup[idx]
	}
	return score
}

func main() {
	lines := util.ReadLines(os.Stdin)

	fmt.Printf("Part 1: %d\n", calculateScore(lines, []int{4, 8, 3, 1, 5, 9, 7, 2, 6}))
	fmt.Printf("Part 2: %d\n", calculateScore(lines, []int{3, 4, 8, 1, 5, 9, 2, 6, 7}))
}
