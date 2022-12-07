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

func NewFile(name string, size int) *File {
	return &File{Name: name, Size: size}
}

func (f *File) String() string {
	return fmt.Sprintf("File{\n  Name: %s,\n  Size:%d\n}", f.Name, f.Size)
}

type Dir struct {
	Name  string
	size  int
	Dirs  map[string]*Dir
	Files map[string]*File
}

func NewDir(name string) *Dir {
	return &Dir{
		Name:  name,
		Dirs:  make(map[string]*Dir),
		Files: make(map[string]*File),
	}
}
func (d *Dir) String() string {
	return fmt.Sprintf("Dir{\n  Name: %s,\n  Size: %d,\n  Subdirs: %+v, \n  Files: %+v\n}", d.Name, d.Size(), d.Dirs, d.Files)
}

func (d *Dir) Cd(path []string) *Dir {
	dir := d
	for _, dirname := range path {
		dir = dir.Dirs[dirname]
	}
	return dir
}

func (d *Dir) MkDir(path []string, name string) {
	d.size = 0 // invalidate cache
	dir := d.Cd(path)
	dir.Dirs[name] = NewDir(name)
}

func (d *Dir) MkFile(path []string, name string, size int) {
	d.size = 0 // invalidate cache
	dir := d.Cd(path)
	dir.Files[name] = NewFile(name, size)
}

func (d *Dir) Size() int {
	if d.size == 0 {
		var size int
		for _, subdir := range d.Dirs {
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
func (d *Dir) AllDirs() []*Dir {
	dirs := []*Dir{}
	for _, dir := range d.Dirs {
		dirs = append(dirs, dir)
		dirs = append(dirs, dir.AllDirs()...)
	}
	return dirs
}

// process the input to build the filesystem
func buildFS(lines []string) *Dir {
	cwd := []string{}
	rootDir := NewDir("/")
	for _, line := range lines {
		toks := strings.Split(line, " ")
		if toks[0] == "$" {
			if toks[1] == "cd" {
				if toks[2] == ".." {
					cwd = cwd[:len(cwd)-1] // pop off last dir
				} else if toks[2] != "/" {
					cwd = append(cwd, toks[2])
				}
			}
		} else { // dir or file
			if toks[0] == "dir" {
				rootDir.MkDir(cwd, toks[1])
			} else { // it's a file
				size, _ := strconv.Atoi(toks[0])
				rootDir.MkFile(cwd, toks[1], size)
			}
		}
	}
	return rootDir
}

// sum all directories with a total size of at most 100,000
func part1(rootDir *Dir) int {
	sum := 0
	for _, dir := range rootDir.AllDirs() {
		if dir.Size() <= 100000 {
			sum += dir.Size()
		}
	}
	return sum
}

// find smallest we can delete to free up enough space
func part2(rootDir *Dir) int {
	totalSpace := 70000000
	needSpace := 30000000
	currentSize := rootDir.Size()
	deleteAmount := needSpace - (totalSpace - currentSize)

	dirSizes := util.Map(rootDir.AllDirs(), func(d *Dir) int {
		return d.Size()
	})
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

	fmt.Printf("Part 1: %d\n", part1(rootDir))
	fmt.Printf("Part 2: %d\n", part2(rootDir))
}
