package util

// Double-Ended QUEue
type Deque[T any] struct {
	values []T
}

// Add one or more elements to the end of the queue
func (s *Deque[T]) Append(values ...T) {
	s.values = append(s.values, values...)
}

// Add one or more elements to the front of the queue
func (s *Deque[T]) Prepend(values ...T) {
	s.values = append(values, s.values...)
}

// Remove and return the element on the end of the queue
func (s *Deque[T]) Pop() (T, bool) {
	if len(s.values) == 0 {
		var zero T
		return zero, false
	}
	last := s.values[len(s.values)-1]
	s.values = s.values[:len(s.values)-1]
	return last, true
}

// Remove and return the given number of elements from the end of the queue
// The order of the elements is preserved.
func (s *Deque[T]) PopN(num int) []T {
	if s.IsEmpty() {
		var zero []T
		return zero
	}
	values := s.values[len(s.values)-num:]
	s.values = s.values[:len(s.values)-num]
	return values
}

// Remove and return the element at the front of the queue
func (s *Deque[T]) PopFront() (T, bool) {
	if s.IsEmpty() {
		var zero T
		return zero, false
	}
	first := s.values[0]
	s.values = s.values[1:len(s.values)]
	return first, true
}

// Remove and return the element at the front of the queue
func (s *Deque[T]) PopFrontN(num int) []T {
	if s.IsEmpty() {
		var zero []T
		return zero
	}
	values := s.values[:num]
	s.values = s.values[num:]
	return values
}

// Returns the first element in the queue. Returns a zero value and false if the queue is empty.
func (s *Deque[T]) First() (T, bool) {
	var zero T
	if s.IsEmpty() {
		return zero, false
	}
	return s.values[0], true
}

// Returns the last element in the queue. Returns a zero value and false if the queue is empty.
func (s *Deque[T]) Last() (T, bool) {
	var zero T
	if s.IsEmpty() {
		return zero, false
	}
	return s.values[len(s.values)-1], true
}

// Return the length of the queue
func (s *Deque[T]) Len() int {
	return len(s.values)
}

// Return true if the queue is empty
func (s *Deque[t]) IsEmpty() bool {
	return len(s.values) == 0
}
