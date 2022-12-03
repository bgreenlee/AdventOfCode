package util

import (
	"bufio"
	"io"
	"os"
)

// Read input from Reader, return as an array of strings
func ReadLines(r io.Reader) []string {
	var lines []string
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}
	return lines
}
