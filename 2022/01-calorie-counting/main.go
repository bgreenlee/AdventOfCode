package main

import (
	"bufio"
	"fmt"
	"os"
	"sort"
	"strconv"
)

func part1(sums []int) int {
	max := 0
	for _, s := range sums {
		if s > max {
			max = s
		}
	}
	return max
}

func part2(sums []int) int {
	sort.Sort(sort.Reverse(sort.IntSlice(sums)))

	return sums[0] + sums[1] + sums[2]
}

func makeSums(lines []string) []int {
	var sums []int
	currentCount := 0
	for _, line := range lines {
		if line == "" {
			sums = append(sums, currentCount)
			currentCount = 0
		} else {
			num, _ := strconv.Atoi(line)
			currentCount += num
		}
	}
	return append(sums, currentCount)
}

func main() {
	var lines []string
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}

	if err := scanner.Err(); err != nil {
		fmt.Println(err)
		os.Exit(-1)
	}

	sums := makeSums(lines)
	fmt.Printf("Part 1: %d\n", part1(sums))
	fmt.Printf("Part 2: %d\n", part2(sums))
}
