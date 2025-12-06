package aoc_2025

import "core:strconv"

parse_i64_or_die :: proc(s: string) -> i64 {
	n, success := strconv.parse_i64(s)
	assert(success, "parse int")
	return n
}

Grid :: struct {
	inner:  []byte,
	width:  i64,
	height: i64,
	stride: i64,
}

grid_at :: proc(grid: Grid, row: i64, col: i64) -> ^byte {
	if row < 0 || col < 0 {return nil}
	if col >= grid.width || row >= grid.height {return nil}
	return &grid.inner[row * grid.stride + col]
}
