package main

import (
	"fmt"
	"os"

	"github.com/bgreenlee/AdventOfCode/tree/main/2022/util"

	mapset "github.com/deckarep/golang-set/v2"
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
	ruck1 := mapset.NewSet[rune]()
	ruck2 := mapset.NewSet[rune]()

	for _, line := range lines {
		runes := []rune(line)
		for i := 0; i < len(runes)/2; i++ {
			ruck1.Add(runes[i])
		}
		for i := len(runes) / 2; i < len(runes); i++ {
			ruck2.Add(runes[i])
		}
		common, _ := ruck1.Intersect(ruck2).Pop()
		score += scoreItem(common)

		ruck1.Clear()
		ruck2.Clear()
	}
	return score
}

func part2(lines []string) int {
	score := 0
	var rucks [3]mapset.Set[rune]
	for i := 0; i < 3; i++ {
		rucks[i] = mapset.NewSet[rune]()
	}

	for lineno, line := range lines {
		runes := []rune(line)
		for i := 0; i < len(runes); i++ {
			rucks[lineno%3].Add(runes[i])
		}
		if lineno%3 == 2 {
			common, _ := rucks[0].Intersect(rucks[1]).Intersect(rucks[2]).Pop()
			score += scoreItem(common)
			for i := 0; i < 3; i++ {
				rucks[i].Clear()
			}
		}
	}
	return score
}

func main() {
	lines := util.ReadLines(os.Stdin)

	fmt.Printf("Part 1: %d\n", part1(lines))
	fmt.Printf("Part 2: %d\n", part2(lines))
}
