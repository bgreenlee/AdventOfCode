package util

// Map transforms the input slice to an output slice by applying the given
// function to each element
func Map[A any, B any](items []A, fn func(A) B) []B {
	out := make([]B, len(items))
	for i, item := range items {
		out[i] = fn(item)
	}
	return out
}

// Filter iterates over the given slice and returns a slice containing only
// the elements for which the given function returned true
func Filter[A any](items []A, fn func(A) bool) []A {
	var out []A
	for _, item := range items {
		if fn(item) {
			out = append(out, item)
		}
	}
	return out
}

// FilterMap performs Filter and Map in one pass
func FilterMap[A any, B any](items []A, fn func(A) (B, bool)) []B {
	var out []B
	for _, item := range items {
		if result, include := fn(item); include {
			out = append(out, result)
		}
	}
	return out
}

