package util

import (
	"reflect"
	"testing"
)

func TestMapIntInt(t *testing.T) {
	in := []int{1, 2, 3}
	out := Map(in, func(i int) int {
		return i * 2
	})
	expect := []int{2, 4, 6}
	if !reflect.DeepEqual(out, expect) {
		t.Fatalf("got %v, expected %v", out, expect)
	}
}

func TestMapStringInt(t *testing.T) {
	in := []string{"one", "two", "three"}
	out := Map(in, func(s string) int {
		return len(s)
	})
	expect := []int{3, 3, 5}
	if !reflect.DeepEqual(out, expect) {
		t.Fatalf("got %v, expected %v", out, expect)
	}
}

func TestFilter(t *testing.T) {
	in := []int{1, 2, 3, 4, 5, 6}
	out := Filter(in, func(i int) bool {
		return i%2 == 0
	})
	expect := []int{2, 4, 6}
	if !reflect.DeepEqual(out, expect) {
		t.Fatalf("got %v, expected %v", out, expect)
	}
}
