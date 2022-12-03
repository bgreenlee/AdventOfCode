package main

import (
	"fmt"
	"os"

	"github.com/bgreenlee/AdventOfCode/tree/main/2022/util"
	set "github.com/deckarep/golang-set/v2"
)

func scoreItem(item rune) int {
	if item >= 'a' && item <= 'z' {
		return int(item) - int('a') + 1
	} else {
		return int(item) - int('A') + 27
	}
}

func part1(lines []string) int {
	score := 0
	for _, line := range lines {
		runes := []rune(line)
		ruck1 := set.NewSet(runes[:len(runes)/2]...)
		ruck2 := set.NewSet(runes[len(runes)/2:]...)
		common, _ := ruck1.Intersect(ruck2).Pop()
		score += scoreItem(common)
	}
	return score
}

func part2(lines []string) int {
	score := 0
	var rucks [3]set.Set[rune]

	for lineno, line := range lines {
		runes := []rune(line)
		rucks[lineno%3] = set.NewSet(runes...)
		if lineno%3 == 2 {
			common, _ := rucks[0].Intersect(rucks[1]).Intersect(rucks[2]).Pop()
			score += scoreItem(common)
		}
	}
	return score
}

func main() {
	lines := util.ReadLines(os.Stdin)

	fmt.Printf("Part 1: %d\n", part1(lines))
	fmt.Printf("Part 2: %d\n", part2(lines))
}
