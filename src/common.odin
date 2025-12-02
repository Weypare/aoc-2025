package aoc_2025

import "core:strconv"

parse_i64_or_die :: proc(s: string) -> i64 {
	n, success := strconv.parse_i64(s)
	assert(success, "parse int")
	return n
}
