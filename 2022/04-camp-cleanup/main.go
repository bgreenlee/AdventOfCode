package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"

	"github.com/bgreenlee/AdventOfCode/tree/main/2022/util"
)

// count number of ranges that are completely contained by the other range
func part1(lines []string) int {
	count := 0
	sep := regexp.MustCompile("[,-]")
	for _, line := range lines {
		// convert line to an array of ints "2-4,6-8" -> [2,4,6,8]
		n := util.Map(sep.Split(line, -1), func(s string) int {
			i, _ := strconv.Atoi(s)
			return i
		})
		if (n[0] <= n[2] && n[1] >= n[3]) || (n[2] <= n[0] && n[3] >= n[1]) {
			count += 1
		}
	}
	return count
}

// count number of ranges that overlap
func part2(lines []string) int {
	count := 0
	sep := regexp.MustCompile("[,-]")
	for _, line := range lines {
		// convert line to an array of ints "2-4,6-8" -> [2,4,6,8]
		n := util.Map(sep.Split(line, -1), func(s string) int {
			i, _ := strconv.Atoi(s)
			return i
		})
		if (n[1] >= n[2] && n[0] <= n[3]) || (n[3] >= n[0] && n[2] <= n[1]) {
			count += 1
		}
	}
	return count
}

func main() {
	lines := util.ReadLines(os.Stdin)

	fmt.Printf("Part 1: %d\n", part1(lines))
	fmt.Printf("Part 2: %d\n", part2(lines))
}
