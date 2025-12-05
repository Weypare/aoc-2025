package aoc_2025

import "core:bytes"
import "core:fmt"
import "core:slice"

day5 :: proc(input_: []byte) {
	input := input_

	count_p1: i64 = 0
	count_p2: i64 = 0

	ranges: [dynamic]Range
	defer delete(ranges)

	for line in bytes.split_iterator(&input, []byte{'\n'}) {
		if len(line) == 0 {break}
		dash_idx := bytes.index_byte(line, '-')
		start := parse_i64_or_die(string(line[:dash_idx]))
		end := parse_i64_or_die(string(line[dash_idx + 1:]))
		append(&ranges, Range{start, end})
	}
	slice.sort_by(ranges[:], proc(i, j: Range) -> bool {return i.end < j.end})

	for i := len(ranges) - 2; i >= 0; i -= 1 {
		lhs := ranges[i]
		rhs := ranges[i + 1]
		switch intersect(lhs, rhs) {
		case .NoIntersection:
		case .RhsConsume:
			ranges[i] = rhs
			ordered_remove(&ranges, i + 1)
		case .LhsConsume:
			ordered_remove(&ranges, i + 1)
		case .Overlap:
			ranges[i].start = min(lhs.start, rhs.start)
			ranges[i].end = max(lhs.end, rhs.end)
			ordered_remove(&ranges, i + 1)
		}
	}

	for line in bytes.split_iterator(&input, []byte{'\n'}) {
		if len(line) == 0 {break}
		id := parse_i64_or_die(string(line))
		for range in ranges {
			if range.start <= id && id <= range.end {
				count_p1 += 1
				break
			}
		}
	}

	for range in ranges {
		count_p2 += range.end - range.start + 1
	}

	fmt.printf("Part 1: %d\n", count_p1)
	fmt.printf("Part 2: %d\n", count_p2)
}

@(private = "file")
Range :: struct {
	start: i64,
	end:   i64,
}

@(private = "file")
Intersection :: enum {
	NoIntersection,
	Overlap,
	LhsConsume,
	RhsConsume,
}

@(private = "file")
intersect :: proc(lhs: Range, rhs: Range) -> Intersection {
	if lhs.start <= rhs.start && rhs.end <= lhs.end {
		return .LhsConsume
	}
	if rhs.start <= lhs.start && lhs.end <= rhs.end {
		return .RhsConsume
	}
	if (lhs.start <= rhs.start && rhs.start <= lhs.end) ||
	   (lhs.start <= rhs.end && rhs.end <= lhs.end) {
		return .Overlap
	}
	return .NoIntersection
}
