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

func Map[A any, B any](in []A, f func(A) B) []B {
	out := make([]B, len(in))
	for i, el := range in {
		out[i] = f(el)
	}
	return out
}

func Filter[A any](els []A, f func(A) bool) []A {
	var out []A
	for _, el := range els {
		if f(el) {
			out = append(out, el)
		}
	}
	return out
}
