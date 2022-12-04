package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"

	"github.com/bgreenlee/AdventOfCode/tree/main/2022/util"
)

func countOverlaps(lines []string, comparisonFn func(n []int) bool) int {
	count := 0
	sep := regexp.MustCompile("[,-]")
	for _, line := range lines {
		// convert line to an array of ints "2-4,6-8" -> [2,4,6,8]
		n := util.Map(sep.Split(line, -1), func(s string) int {
			i, _ := strconv.Atoi(s)
			return i
		})
		if comparisonFn(n) {
			count += 1
		}
	}
	return count
}

// ranges in which one completely covers the other
func overlapComplete(n []int) bool {
	return (n[0] <= n[2] && n[1] >= n[3]) || (n[2] <= n[0] && n[3] >= n[1])
}

// ranges that overlap partially
func overlapPartial(n []int) bool {
	return (n[1] >= n[2] && n[0] <= n[3]) || (n[3] >= n[0] && n[2] <= n[1])
}

func main() {
	lines := util.ReadLines(os.Stdin)

	fmt.Printf("Part 1: %d\n", countOverlaps(lines, overlapComplete))
	fmt.Printf("Part 2: %d\n", countOverlaps(lines, overlapPartial))
}
