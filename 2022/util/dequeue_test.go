package util

import (
	"reflect"
	"testing"
)

func TestAppendPop(t *testing.T) {
	var deque Deque[int]
	deque.Append(1)
	deque.Append(2)
	deque.Append(3)
	last, _ := deque.Pop()
	if last != 3 {
		t.Fatalf("Expected 3, got %d", last)
	}
}

func TestAppendPopMultiple(t *testing.T) {
	var deque Deque[int]
	deque.Append([]int{1, 2, 3}...)
	last, _ := deque.Pop()
	if last != 3 {
		t.Fatalf("Expected 3, got %d", last)
	}
}

func TestPrependPopFront(t *testing.T) {
	var deque Deque[int]
	deque.Prepend(1)
	deque.Prepend(2)
	deque.Prepend(3)
	first, _ := deque.PopFront()
	if first != 3 {
		t.Fatalf("Expected 3, got %d", first)
	}
}

func TestAppendPopFront(t *testing.T) {
	var deque Deque[int]
	deque.Append(1)
	deque.Append(2)
	deque.Append(3)
	first, _ := deque.PopFront()
	if first != 1 {
		t.Fatalf("Expected 3, got %d", first)
	}
}

func TestPopN(t *testing.T) {
	var deque Deque[int]
	deque.Append(1)
	deque.Append(2)
	deque.Append(3)
	values := deque.PopN(2)
	expected := []int{2, 3}
	if !reflect.DeepEqual(values, expected) {
		t.Fatalf("Expected %v, got %v", expected, values)
	}
}

func TestPopFrontN(t *testing.T) {
	var deque Deque[int]
	deque.Append(1)
	deque.Append(2)
	deque.Append(3)
	values := deque.PopFrontN(2)
	expected := []int{1, 2}
	if !reflect.DeepEqual(values, expected) {
		t.Fatalf("Expected %v, got %v", expected, values)
	}
}
