package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"

	"github.com/bgreenlee/AdventOfCode/tree/main/2022/util"
)

type Stack = util.Deque[rune]

type Move struct {
	num  int
	from int
	to   int
}

func parseProblem(lines []string) ([]Stack, []Move) {
	// parse stacks
	var stacks []Stack
	var lineno int
	for lineno = 0; lineno < len(lines); lineno++ {
		runes := []rune(lines[lineno])
		if runes[1] == '1' {
			break
		}

		// make sure stacks is big enough
		for {
			if len(stacks) > (len(runes)-1)/4 {
				break
			}
			stacks = append(stacks, Stack{})
		}

		for i := 1; i < len(runes); i += 4 {
			if runes[i] != ' ' {
				stacks[(i-1)/4].Prepend(runes[i])
			}
		}
	}

	// parse moves
	var moves []Move
	var moveRE = regexp.MustCompile(`move (\d+) from (\d+) to (\d+)`)
	for i := lineno + 2; i < len(lines); i++ {
		match := moveRE.FindStringSubmatch(lines[i])
		if match != nil {
			num, _ := strconv.Atoi(match[1])
			from, _ := strconv.Atoi(match[2])
			to, _ := strconv.Atoi(match[3])
			moves = append(moves, Move{num, from, to})
		}
	}

	return stacks, moves
}

func part1(lines []string) string {
	stacks, moves := parseProblem(lines)
	for _, move := range moves {
		for i := 0; i < move.num; i++ {
			// move items one at a time
			item, _ := stacks[move.from-1].Pop()
			stacks[move.to-1].Append(item)
		}
	}
	// get top of each stack
	var tops []rune
	for _, stack := range stacks {
		top, _ := stack.Last()
		tops = append(tops, top)
	}
	return string(tops)
}

func part2(lines []string) string {
	stacks, moves := parseProblem(lines)
	for _, move := range moves {
		items := stacks[move.from-1].PopN(move.num)
		stacks[move.to-1].Append(items...)
	}
	// get top of each stack
	var tops []rune
	for _, stack := range stacks {
		top, _ := stack.Last()
		tops = append(tops, top)
	}
	return string(tops)
}

func main() {
	lines, _ := util.ReadLines(os.Stdin)

	fmt.Printf("Part 1: %s\n", part1(lines))
	fmt.Printf("Part 2: %s\n", part2(lines))
}
