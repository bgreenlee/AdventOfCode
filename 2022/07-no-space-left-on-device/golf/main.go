package main

import (
	"fmt"
	"os"
	"sort"
	"strconv"
	"strings"

	"github.com/bgreenlee/AdventOfCode/tree/main/2022/util"
)

func main() {
	lines, _ := util.ReadLines(os.Stdin)

	cwd := []string{}
	dirs := make(map[string]int)
	for _, line := range lines {
		toks := strings.Split(line, " ")
		if toks[0] == "$" {
			if toks[1] == "cd" {
				if toks[2] == ".." {
					cwd = cwd[:len(cwd)-1]
				} else {
					cwd = append(cwd, toks[2])
				}
			}
		} else if toks[0] != "dir" {
			size, _ := strconv.Atoi(toks[0])
			for i := 0; i < len(cwd); i++ {
				dirs[strings.Join(cwd[:len(cwd)-i], "/")] += size
			}
		}
	}

	// part 1
	sum := 0
	sizes := []int{}
	for _, size := range dirs {
		sizes = append(sizes, size)
		if size <= 100000 {
			sum += size
		}
	}
	fmt.Printf("Part 1: %d\n", sum)

	// part 2
	sort.Ints(sizes)
	deleteAmount := 30000000 - (70000000 - dirs["/"])
	for _, size := range sizes {
		if size >= deleteAmount {
			fmt.Printf("Part 2: %d\n", size)
			break
		}
	}
}
