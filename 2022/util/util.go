package util

import (
	"bufio"
	"io"
)

// Read input from Reader, return as an array of strings
func ReadLines(r io.Reader) []string {
	var lines []string
	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}
	return lines
}
