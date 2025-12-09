package aoc_2025

import "core:bytes"
import "core:fmt"

day4 :: proc(input: []byte, _: bool) {
	trimmed := bytes.trim_right_space(input)

	count_p1: i64 = 0
	count_p2: i64 = 0

	width: i64 = auto_cast bytes.index_byte(trimmed, '\n')
	height: i64 = auto_cast (1 + bytes.count(trimmed, []byte{'\n'}))

	grid := Grid {
		inner  = input,
		width  = width,
		height = height,
		stride = width + 1,
	}

	for row in 0 ..< grid.height {
		for col in 0 ..< grid.width {
			if value := grid_at(grid, row, col); value^ != PAPER {continue}
			if is_accessible(grid, row, col) {
				count_p1 += 1
			}
		}
	}

	generation: u8 = PAPER + 1
	assert(generation > EMPTY)
	for {
		did_remove := false
		for row in 0 ..< grid.height {
			for col in 0 ..< grid.width {
				ptr := grid_at(grid, row, col)
				if ptr^ != PAPER {continue}
				if is_accessible_with_generation(grid, row, col, generation) {
					did_remove = true
					count_p2 += 1
					ptr^ = generation
				}
			}
		}
		if !did_remove {break}
		generation += 1
	}

	fmt.printf("Part 1: %d\n", count_p1)
	fmt.printf("Part 2: %d\n", count_p2)
}

@(private = "file")
PAPER :: '@'
@(private = "file")
EMPTY :: '.'

@(private = "file")
is_accessible :: proc(grid: Grid, row: i64, col: i64) -> bool {
	return is_accessible_with_generation(grid, row, col, 0)
}

@(private = "file")
is_accessible_with_generation :: proc(grid: Grid, row: i64, col: i64, gen: byte) -> bool {
	count := 0

	for dx in -1 ..= 1 {
		for dy in -1 ..= 1 {
			if dx == 0 && dy == 0 {continue}
			c := col + auto_cast dx
			r := row + auto_cast dy
			value := grid_at(grid, r, c)
			if value == nil {continue}
			if value^ == PAPER || value^ == gen {
				count += 1
			}
		}
	}

	return count < 4
}
