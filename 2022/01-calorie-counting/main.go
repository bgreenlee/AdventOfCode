package main

import (
	"bufio"
	"fmt"
	"os"
	"sort"
	"strconv"
)

func part1(lines []string) int {
	maxCount := 0
	currentCount := 0
	for _, line := range lines {
		if line == "" {
			if currentCount > maxCount {
				maxCount = currentCount
			}
			currentCount = 0
		} else {
			num, _ := strconv.Atoi(line)
			currentCount += num
		}
	}
	if currentCount > maxCount {
		maxCount = currentCount
	}

	return maxCount
}

func part2(lines []string) int {
	var counts []int
	currentCount := 0
	for _, line := range lines {
		if line == "" {
			counts = append(counts, currentCount)
			currentCount = 0
		} else {
			num, _ := strconv.Atoi(line)
			currentCount += num
		}
	}
	counts = append(counts, currentCount)
	sort.Sort(sort.Reverse(sort.IntSlice(counts)))

	return counts[0] + counts[1] + counts[2]
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

	fmt.Printf("Part 1: %d\n", part1(lines))
	fmt.Printf("Part 2: %d\n", part2(lines))
}
