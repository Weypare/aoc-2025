package aoc_2025

import "core:bytes"
import "core:fmt"
import "core:math"

day2 :: proc(input: []byte, _: bool) {
	trimmed := bytes.trim_space(input)

	sum_p1: i64 = 0
	sum_p2: i64 = 0
	seen_ids_p2 := make(map[i64]bool)
	defer delete(seen_ids_p2)

	for range in bytes.split_iterator(&trimmed, []byte{','}) {
		dash_idx := bytes.index_byte(range, '-')
		start := parse_i64_or_die(string(range[:dash_idx]))
		end := parse_i64_or_die(string(range[dash_idx + 1:]))
		impl(start, end, &sum_p1, nil, 2)
		impl(start, end, &sum_p2, &seen_ids_p2)
	}

	fmt.printf("Part 1: %d\n", sum_p1)
	fmt.printf("Part 2: %d\n", sum_p2)
}

POWERS_OF_10 := []i64{1, 10, 100, 1000, 10000, 100000}

@(private = "file")
make_invalid_id_from_repetitions :: proc(val: i64, val_width: i64, reps: i64) -> i64 {
	out := val
	for _ in 0 ..< reps - 1 {
		out *= POWERS_OF_10[val_width]
		out += val
	}
	return out
}

@(private = "file")
impl :: proc(
	start: i64,
	end: i64,
	sum: ^i64,
	seen_invalid_ids: ^map[i64]bool = nil,
	max_reps: i64 = 32,
) {
	start_width := 1 + cast(i64)math.log10(cast(f32)start)
	end_width := 1 + cast(i64)math.log10(cast(f32)end)

	for reps in 2 ..= math.min(max_reps, end_width) {
		width_loop: for width in start_width ..= end_width {
			if width % reps != 0 {continue}
			pattern_width := width / reps
			for pattern in POWERS_OF_10[pattern_width - 1] ..< POWERS_OF_10[pattern_width] {
				candidate := make_invalid_id_from_repetitions(pattern, pattern_width, reps)
				if candidate < start {continue}
				if candidate > end {break width_loop}
				if seen_invalid_ids != nil {
					if candidate in seen_invalid_ids {continue}
					seen_invalid_ids^[candidate] = true
				}
				sum^ += candidate
			}
		}
	}
}
