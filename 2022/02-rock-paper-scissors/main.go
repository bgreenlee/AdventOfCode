package main

import (
	"bufio"
	"fmt"
	"os"
)

func part1(lines []string) int {
	score := 0
	for _, line := range lines {
		switch line {
		case "A X": // rock draws rock (1 + 3)
			score += 4
		case "A Y": // paper defeats rock (2 + 6)
			score += 8
		case "A Z": // scissors loses to rock (3 + 0)
			score += 3
		case "B X": // rock loses to paper (1 + 0)
			score += 1
		case "B Y": // paper draws paper (2 + 3)
			score += 5
		case "B Z": // scissors defeats paper (3 + 6)
			score += 9
		case "C X": // rock defeats scissors (1 + 6)
			score += 7
		case "C Y": // paper loses to scissors (2 + 0)
			score += 2
		case "C Z": // scissors draws scissors (3 + 3)
			score += 6
		}
	}
	return score
}

func part2(lines []string) int {
	score := 0
	for _, line := range lines {
		switch line {
		case "A X": // lose with scissors (0 + 3)
			score += 3
		case "A Y": // draw with rock (3 + 1)
			score += 4
		case "A Z": // win with paper (6 + 2)
			score += 8
		case "B X": // lose with rock (0 + 1)
			score += 1
		case "B Y": // draw with paper (3 + 2)
			score += 5
		case "B Z": // win with scissors (6 + 3)
			score += 9
		case "C X": // lose with paper (0 + 2)
			score += 2
		case "C Y": // draw with scissors (3 + 3)
			score += 6
		case "C Z": // win with rock (6 + 1)
			score += 7
		}
	}
	return score
}

func main() {
	// read input from stdin
	var lines []string
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}

	fmt.Printf("Part 1: %d\n", part1(lines))
	fmt.Printf("Part 2: %d\n", part2(lines))
}
