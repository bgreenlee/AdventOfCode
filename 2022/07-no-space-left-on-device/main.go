package main

import (
	"fmt"
	"os"
	"sort"
	"strconv"
	"strings"

	"github.com/bgreenlee/AdventOfCode/tree/main/2022/util"
)

type File struct {
	Name string
	Size int
}

func (f *File) String() string {
	return fmt.Sprintf("File{\n  Name: %s,\n  Size:%d\n}", f.Name, f.Size)
}

type Dir struct {
	Name    string
	size    int
	Subdirs map[string]*Dir
	Files   map[string]*File
}

func (d *Dir) String() string {
	return fmt.Sprintf("Dir{\n  Name: %s,\n  Size: %d,\n  Subdirs: %+v, \n  Files: %+v\n}", d.Name, d.Size(), d.Subdirs, d.Files)
}

func (d *Dir) AddSubdir(path []string, name string) {
	d.size = 0 // invalidate cache
	curDir := d
	for _, dirname := range path {
		if dirname == "/" {
			continue
		}
		curDir = curDir.Subdirs[dirname]
	}
	curDir.Subdirs[name] = &Dir{
		Name:    name,
		Subdirs: make(map[string]*Dir),
		Files:   make(map[string]*File),
	}
}

func (d *Dir) AddFile(path []string, name string, size int) {
	d.size = 0 // invalidate cache
	curDir := d
	for _, dirname := range path {
		if dirname == "/" {
			continue
		}
		curDir = curDir.Subdirs[dirname]
	}
	curDir.Files[name] = &File{Name: name, Size: size}
}

func (d *Dir) Size() int {
	if d.size == 0 {
		var size int
		for _, subdir := range d.Subdirs {
			size += subdir.Size()
		}
		for _, file := range d.Files {
			size += file.Size
		}
		d.size = size
	}
	return d.size
}

// recursively get all subdirs
func (d *Dir) AllSubdirs() []*Dir {
	subdirs := []*Dir{}
	for _, subdir := range d.Subdirs {
		subdirs = append(subdirs, subdir)
		subdirs = append(subdirs, subdir.AllSubdirs()...)
	}
	return subdirs
}

func buildFS(lines []string) Dir {
	cwd := []string{}
	rootDir := Dir{
		Name:    "/",
		Subdirs: make(map[string]*Dir),
		Files:   make(map[string]*File),
	}
	for _, line := range lines {
		toks := strings.Split(line, " ")
		if toks[0] == "$" {
			if toks[1] == "cd" {
				if toks[2] == ".." {
					cwd = cwd[:len(cwd)-1] // pop off last dir
				} else {
					cwd = append(cwd, toks[2])
				}
			}
		} else { // dir or file
			if toks[0] == "dir" {
				rootDir.AddSubdir(cwd, toks[1])
			} else { // it's a file
				size, _ := strconv.Atoi(toks[0])
				rootDir.AddFile(cwd, toks[1], size)
			}
		}
	}
	return rootDir
}

func part1(rootDir *Dir) int {
	// sum all directories with a total size of at most 100,000
	sum := 0
	for _, dir := range rootDir.AllSubdirs() {
		if dir.Size() <= 100000 {
			sum += dir.Size()
		}
	}
	return sum
}

func part2(rootDir *Dir) int {
	totalSpace := 70000000
	currentSize := rootDir.Size()
	needSpace := 30000000
	deleteAmount := needSpace - (totalSpace - currentSize)

	dirSizes := util.Map(rootDir.AllSubdirs(), func(d *Dir) int {
		return d.Size()
	})
	// sort the dirSizes
	sort.Ints(dirSizes)
	for _, size := range dirSizes {
		if size >= deleteAmount {
			return size
		}
	}
	return 0
}

func main() {
	lines, _ := util.ReadLines(os.Stdin)
	rootDir := buildFS(lines)

	fmt.Printf("Part 1: %d\n", part1(&rootDir))
	fmt.Printf("Part 2: %d\n", part2(&rootDir))
}
