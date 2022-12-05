package util

type Deque[T any] struct {
	values []T
}

func (s *Deque[T]) PushBack(value T) {
	s.values = append(s.values, value)
}

func (s *Deque[T]) PopBack() (T, bool) {
	if len(s.values) == 0 {
		var zero T
		return zero, false
	}
	last := s.values[len(s.values)-1]
	s.values = s.values[:len(s.values)-1]
	return last, true
}

func (s *Deque[T]) PushFront(value T) {
	s.values = append([]T{value}, s.values...)
}

func (s *Deque[T]) PopFront() (T, bool) {
	if len(s.values) == 0 {
		var zero T
		return zero, false
	}
	first := s.values[0]
	s.values = s.values[1:len(s.values)]
	return first, true
}

func (s *Deque[T]) Len() int {
	return len(s.values)
}

func (s *Deque[t]) IsEmpty() bool {
	return len(s.values) == 0
}
