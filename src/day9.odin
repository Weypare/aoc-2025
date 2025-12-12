package aoc_2025

import "core:bytes"
import "core:fmt"
import "core:math"
import "core:slice"

@(private = "file")
Vec2 :: [2]f64

day9 :: proc(input_: []byte, _: bool) {
	input := input_

	red_tiles: [dynamic]Vec2
	defer delete(red_tiles)

	for line in bytes.split_iterator(&input, []byte{'\n'}) {
		if len(line) == 0 {continue}
		l := line
		x, _ := bytes.split_iterator(&l, []byte{','})
		y := l
		append(
			&red_tiles,
			Vec2{cast(f64)parse_i64_or_die(string(x)), cast(f64)parse_i64_or_die(string(y))},
		)
	}

	part1(red_tiles[:])
	part2(red_tiles[:])
}

@(private = "file")
part1 :: proc(red_tiles: []Vec2) {
	max_area: f64 = 0
	for t1, i in red_tiles {
		for t2 in red_tiles[i + 1:] {
			dx := math.abs(t1.x - t2.x) + 1
			dy := math.abs(t1.y - t2.y) + 1
			area := dx * dy
			if area > max_area {max_area = area}
		}
	}

	fmt.printfln("Part 1: %d", cast(i64)max_area)
}

// FIXME: polygon check is slow af
@(private = "file")
part2 :: proc(red_tiles: []Vec2) {
	max_area: f64 = 0

	Square :: struct {
		top_left:     Vec2,
		bottom_right: Vec2,
		area:         f64,
	}

	make_square :: proc(a, b: Vec2) -> Square {
		low_x := min(a.x, b.x)
		high_x := max(a.x, b.x)
		low_y := min(a.y, b.y)
		high_y := max(a.y, b.y)

		dx := high_x - low_x + 1
		dy := high_y - low_y + 1
		area := dx * dy

		return Square {
			top_left = Vec2{low_x, low_y},
			bottom_right = Vec2{high_x, high_y},
			area = area,
		}
	}

	contains_square :: proc(container, containee: Square) -> bool {
		return(
			container.top_left.x <= containee.top_left.x &&
			container.top_left.y <= containee.top_left.y &&
			container.bottom_right.x >= containee.bottom_right.x &&
			container.bottom_right.y >= containee.bottom_right.y \
		)
	}

	squares: [dynamic]Square
	defer delete(squares)

	for t1, i in red_tiles {
		for t2 in red_tiles[i + 1:] {
			append(&squares, make_square(t1, t2))
		}
	}
	slice.sort_by_key(squares[:], proc(s: Square) -> f64 {return s.area})

	bad_squares: [dynamic]Square
	defer delete(bad_squares)

	outer: for s, i in squares {
		fmt.printf("\rProgress %d/%d", i + 1, len(squares))

		for containee in bad_squares {
			if contains_square(s, containee) {
				continue outer
			}
		}

		for x in s.top_left.x ..= s.bottom_right.x {
			points := [2]Vec2{Vec2{x, s.top_left.y}, Vec2{x, s.bottom_right.y}}
			for point in points {
				if !is_inside_non_convex_polygon(red_tiles, point) {
					append(&bad_squares, s)
					continue outer
				}
			}
		}
		for y in s.top_left.y ..= s.bottom_right.y {
			points := [2]Vec2{Vec2{s.top_left.x, y}, Vec2{s.bottom_right.x, y}}
			for point in points {
				if !is_inside_non_convex_polygon(red_tiles, point) {
					append(&bad_squares, s)
					continue outer
				}
			}
		}

		max_area = s.area
	}

	fmt.printfln("\nPart 2: %d", cast(i64)max_area)
}

@(private = "file")
is_inside_non_convex_polygon :: proc(polygon: []Vec2, point: Vec2) -> bool {
	assert(len(polygon) >= 3)

	winding_number := 0
	for i in 0 ..< len(polygon) {
		a := polygon[i]
		b := polygon[(i + 1) % len(polygon)]

		edge := b - a
		a_point_vec := point - a
		cross := edge.x * a_point_vec.y - a_point_vec.x * edge.y

		if min(a.x, b.x) <= point.x &&
		   point.x <= max(a.x, b.x) &&
		   min(a.y, b.y) <= point.y &&
		   point.y <= max(a.y, b.y) {
			if cross == 0 {return true}
		}

		a_below := a.y <= point.y
		b_below := b.y <= point.y
		if a_below != b_below {
			if (b.y > a.y) == (cross > 0) {
				winding_number += 1
			} else {
				winding_number -= 1
			}
		}
	}

	return winding_number == 0
}
