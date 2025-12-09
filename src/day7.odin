package aoc_2025

import "core:bytes"
import "core:fmt"
import "core:slice"

day7 :: proc(input_: []byte, _: bool) {
	input := input_

	width: i64 = auto_cast bytes.index_byte(input, '\n')
	stride := width + 1

	height: i64 = 0
	for line in bytes.split_iterator(&input, []byte{'\n'}) {
		if len(line) == 0 {break}
		height += 1
	}
	grid := Grid {
		width  = width,
		height = height,
		stride = stride,
		inner  = input_,
	}

	part1(grid)
	part2(grid)
}


@(private = "file")
Pos :: struct {
	row: i64,
	col: i64,
}

@(private = "file")
part1 :: proc(grid: Grid) {
	start_idx: i64 = auto_cast bytes.index_byte(grid.inner, 'S')
	start := Pos {
		row = start_idx / grid.stride,
		col = start_idx % grid.stride,
	}

	beams: [dynamic]Pos
	defer delete(beams)

	// the [0..first^) portion of the array is assumed to be unused
	unordered_remove_into_array_prefix :: proc(array: []$T, first: ^int, i: int) {
		array[i] = array[first^]
		first^ += 1
	}

	first_beam_at_level := 0
	split_count := 0
	append(&beams, start)
	for first_beam_at_level < len(beams) {
		level := beams[first_beam_at_level].row
		for i := first_beam_at_level; i < len(beams); i += 1 {
			beam := &beams[i]
			if beam.row > level {break}
			assert(beam.row == level)

			beam.row += 1
			new := grid_at(grid, beam.row, beam.col)
			if new == nil {
				first_beam_at_level += 1
				continue
			}

			switch new^ {
			case '.':
				// if a previous split already created a beam in this pos, we have to remove the current beam
				_, found := slice.linear_search(beams[first_beam_at_level:i], beam^)
				if found {unordered_remove_into_array_prefix(beams[:], &first_beam_at_level, i)}
			case '^':
				if beam.col > 0 {
					new_beam := Pos {
						row = beam.row,
						col = beam.col - 1,
					}
					_, found := slice.linear_search(beams[first_beam_at_level:], new_beam)
					if !found {append(&beams, new_beam)}
				}
				if beam.col + 1 < grid.width {
					new_beam := Pos {
						row = beam.row,
						col = beam.col + 1,
					}
					_, found := slice.linear_search(beams[first_beam_at_level:], new_beam)
					if !found {append(&beams, new_beam)}
				}

				unordered_remove_into_array_prefix(beams[:], &first_beam_at_level, i)
				split_count += 1
			case:
				fmt.printf("Unexpected cell value: '%c'\n", new^)
				panic("Unexpected cell value")
			}
		}
	}

	fmt.printf("Part 1: %d\n", split_count)
}

@(private = "file")
part2 :: proc(grid: Grid) {
	start_idx: i64 = auto_cast bytes.index_byte(grid.inner, 'S')
	start := Pos {
		row = start_idx / grid.stride,
		col = start_idx % grid.stride,
	}

	cache: map[Pos]i64
	defer delete(cache)

	// ...S...
	// .......
	// ...^...
	// .......
	// ..^....
	// ....^..
	// .......
	// 1 + (1 + (0 + 0)) + (1 + (0 + 0)) == 3

	// ...S...
	// .......
	// ...^...
	// .......
	// ..^....
	// .......
	// 1 + (1 + (0 + 0)) + (0) == 2

	count_splits_starting_from :: proc(grid: Grid, start: Pos, cache: ^map[Pos]i64) -> i64 {
		if start in cache {
			return cache[start]
		}

		cur := grid_at(grid, start.row, start.col)
		if cur == nil {
			cache[start] = 0
			return 0
		}

		switch cur^ {
		case 'S':
			fallthrough
		case '.':
			new_pos := Pos {
				row = start.row + 1,
				col = start.col,
			}
			count := count_splits_starting_from(grid, new_pos, cache)
			cache[start] = count
			return count
		case '^':
			left := Pos {
				row = start.row,
				col = start.col - 1,
			}
			right := Pos {
				row = start.row,
				col = start.col + 1,
			}
			l := count_splits_starting_from(grid, left, cache)
			r := count_splits_starting_from(grid, right, cache)
			cache[start] = 1 + l + r
			return 1 + l + r
		case:
			fmt.printf("Unexpected cell value: '%c'\n", cur^)
			panic("Unexpected cell value")
		}
		panic("Unreachable")
	}

	// each split introduces an additional timeline, therefore we have to account for initial timeline existing, therefore +1
	count := 1 + count_splits_starting_from(grid, start, &cache)
	fmt.printf("Part 2: %d\n", count)
}
