package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"

	"github.com/bgreenlee/AdventOfCode/tree/main/2022/util"
)

var sepRE = regexp.MustCompile("[,-]")

// signature for function that takes an array of ints representing the ranges,
// and returns true if those ranges satisfy the comparison function
type comparisonFunc func([]int) bool

// ranges in which one completely covers the other
func isCompleteOverlap(n []int) bool {
	return (n[0] <= n[2] && n[1] >= n[3]) || (n[2] <= n[0] && n[3] >= n[1])
}

// ranges that overlap partially
func isPartialOverlap(n []int) bool {
	return (n[1] >= n[2] && n[0] <= n[3]) || (n[3] >= n[0] && n[2] <= n[1])
}

// convert line to an array of ints "2-4,6-8" -> [2,4,6,8]
func parseLine(line string) []int {
	return util.Map(sepRE.Split(line, -1), func(s string) int {
		i, _ := strconv.Atoi(s)
		return i
	})
}

// count the number of lines that satisfy the given overlap function
func countOverlaps(lines []string, fn comparisonFunc) int {
	ranges := util.Map(lines, parseLine)
	return len(util.Filter(ranges, fn))
}

func main() {
	lines, _ := util.ReadLines(os.Stdin)

	fmt.Printf("Part 1: %d\n", countOverlaps(lines, isCompleteOverlap))
	fmt.Printf("Part 2: %d\n", countOverlaps(lines, isPartialOverlap))
}
