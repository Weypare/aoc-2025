package aoc_2025

import "core:bytes"
import "core:fmt"
import "core:math"


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
	}

	contains_square :: proc(container, containee: Square) -> bool {
		return(
			container.top_left.x <= containee.top_left.x &&
			container.top_left.y <= containee.top_left.y &&
			container.bottom_right.x >= containee.bottom_right.x &&
			container.bottom_right.y >= containee.bottom_right.y \
		)
	}

	bad_squares: [dynamic]Square
	defer delete(bad_squares)

	for t1, i in red_tiles {
		fmt.printfln("Progress %d/%d", i + 1, len(red_tiles))
		tile_loop: for t2 in red_tiles[i + 1:] {
			dx := math.abs(t1.x - t2.x) + 1
			dy := math.abs(t1.y - t2.y) + 1
			area := dx * dy
			if area > max_area {
				low_x := min(t1.x, t2.x)
				high_x := max(t1.x, t2.x)
				low_y := min(t1.y, t2.y)
				high_y := max(t1.y, t2.y)

				square := Square {
					top_left     = Vec2{low_x, low_y},
					bottom_right = Vec2{high_x, high_y},
				}
				for containee in bad_squares {
					if contains_square(square, containee) {
						continue tile_loop
					}
				}

				for x in low_x ..= high_x {
					points := [2]Vec2{Vec2{x, low_y}, Vec2{x, high_y}}
					for point in points {
						if !is_inside_non_convex_polygon(red_tiles, point) {
							append(&bad_squares, square)
							continue tile_loop
						}
					}
				}
				for y in low_y ..= high_y {
					points := [2]Vec2{Vec2{low_x, y}, Vec2{high_x, y}}
					for point in points {
						if !is_inside_non_convex_polygon(red_tiles, point) {
							append(&bad_squares, square)
							continue tile_loop
						}
					}
				}

				fmt.printfln("Found new largest area=%f %v %v", area, t1, t2)
				max_area = area
			}
		}
	}

	fmt.printfln("Part 2: %d", cast(i64)max_area)
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
