package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"

	"github.com/bgreenlee/AdventOfCode/tree/main/2022/util"
)

func countOverlaps(lines []string, comparisonFn func(n []int) bool) int {
	sep := regexp.MustCompile("[,-]")
	// filter down to lines that satisfy the comparison function
	return len(util.Filter(lines, func(line string) bool {
		// convert line to an array of ints "2-4,6-8" -> [2,4,6,8]
		n := util.Map(sep.Split(line, -1), func(s string) int {
			i, _ := strconv.Atoi(s)
			return i
		})
		return comparisonFn(n)
	}))
}

// ranges in which one completely covers the other
func isCompleteOverlap(n []int) bool {
	return (n[0] <= n[2] && n[1] >= n[3]) || (n[2] <= n[0] && n[3] >= n[1])
}

// ranges that overlap partially
func isPartialOverlap(n []int) bool {
	return (n[1] >= n[2] && n[0] <= n[3]) || (n[3] >= n[0] && n[2] <= n[1])
}

func main() {
	lines := util.ReadLines(os.Stdin)

	fmt.Printf("Part 1: %d\n", countOverlaps(lines, isCompleteOverlap))
	fmt.Printf("Part 2: %d\n", countOverlaps(lines, isPartialOverlap))
}
