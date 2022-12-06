package main

import (
	"fmt"
	"os"

	"github.com/bgreenlee/AdventOfCode/tree/main/2022/util"
	set "github.com/deckarep/golang-set/v2"
)

func solve(line string, num int) int {
	runes := []rune(line)
	for i := 0; i < len(runes)-num; i++ {
		charset := set.NewSet(runes[i : i+num]...)
		if charset.Cardinality() == num {
			return i + num
		}
	}
	return 0
}

func main() {
	lines, _ := util.ReadLines(os.Stdin)

	fmt.Printf("Part 1: %d\n", solve(lines[0], 4))
	fmt.Printf("Part 2: %d\n", solve(lines[0], 14))
}
