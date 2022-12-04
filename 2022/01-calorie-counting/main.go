package main

import (
	"fmt"
	"os"
	"sort"
	"strconv"

	"github.com/bgreenlee/AdventOfCode/tree/main/2022/util"
)

// return the max sum
func part1(sums []int) int {
	max := 0
	for _, s := range sums {
		if s > max {
			max = s
		}
	}
	return max
}

// return the sum of the top three sums
func part2(sums []int) int {
	sort.Sort(sort.Reverse(sort.IntSlice(sums)))
	return sums[0] + sums[1] + sums[2]
}

// return an array of sums of each group of numbers in the input
func makeSums(lines []string) []int {
	var sums []int
	sum := 0
	for _, line := range lines {
		if line == "" {
			sums = append(sums, sum)
			sum = 0
		} else {
			num, _ := strconv.Atoi(line)
			sum += num
		}
	}
	return append(sums, sum)
}

func main() {
	lines, _ := util.ReadLines(os.Stdin)

	sums := makeSums(lines)
	fmt.Printf("Part 1: %d\n", part1(sums))
	fmt.Printf("Part 2: %d\n", part2(sums))
}
