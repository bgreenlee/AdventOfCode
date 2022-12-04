package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/bgreenlee/AdventOfCode/tree/main/2022/util"
)

func part1(lines []string) int {
	count := 0
	for _, line := range lines {
		elves := strings.Split(line, ",")
		p1 := strings.Split(elves[0], "-")
		p2 := strings.Split(elves[1], "-")
		s1, _ := strconv.Atoi(p1[0])
		e1, _ := strconv.Atoi(p1[1])
		s2, _ := strconv.Atoi(p2[0])
		e2, _ := strconv.Atoi(p2[1])
		if s1 <= s2 && e1 >= e2 || s2 <= s1 && e2 >= e1 {
			count += 1
		}
	}
	return count
}

func part2(lines []string) int {
	count := 0
	for _, line := range lines {
		elves := strings.Split(line, ",")
		p1 := strings.Split(elves[0], "-")
		p2 := strings.Split(elves[1], "-")
		s1, _ := strconv.Atoi(p1[0])
		e1, _ := strconv.Atoi(p1[1])
		s2, _ := strconv.Atoi(p2[0])
		e2, _ := strconv.Atoi(p2[1])
		if e1 >= s2 && s1 <= e2 || e2 >= s1 && s2 <= e1 {
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
