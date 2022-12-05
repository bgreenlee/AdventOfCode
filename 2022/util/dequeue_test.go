package util

import "testing"

func TestPushPopBack(t *testing.T) {
	var deque Deque[int]
	deque.PushBack(1)
	deque.PushBack(2)
	deque.PushBack(3)
	last, _ := deque.PopBack()
	if last != 3 {
		t.Fatalf("Expected 3, got %d", last)
	}
}

func TestPushPopFront(t *testing.T) {
	var deque Deque[int]
	deque.PushFront(1)
	deque.PushFront(2)
	deque.PushFront(3)
	first, _ := deque.PopFront()
	if first != 3 {
		t.Fatalf("Expected 3, got %d", first)
	}
}

func TestPushBackPopFront(t *testing.T) {
	var deque Deque[int]
	deque.PushBack(1)
	deque.PushBack(2)
	deque.PushBack(3)
	first, _ := deque.PopFront()
	if first != 1 {
		t.Fatalf("Expected 3, got %d", first)
	}
}
