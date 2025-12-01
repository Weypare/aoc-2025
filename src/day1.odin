package aoc_2025

import "core:bytes"
import "core:fmt"
import "core:strconv"

day1 :: proc(input_: []byte) {
	input := input_
	dial: i64 = 50
	zero_count_p1: i64 = 0
	zero_count_p2: i64 = 0
	for line in bytes.split_iterator(&input, []byte{'\n'}) {
		if len(line) == 0 {continue}
		count, success := strconv.parse_i64(string(line[1:]))
		assert(success, "invalid int")
		full := count / 100
		rest := count % 100
		switch line[0] {
		case 'L':
			zero_count_p2 += auto_cast (dial != 0 && dial - rest <= 0)
			zero_count_p2 += full
			dial -= rest
		case 'R':
			zero_count_p2 += auto_cast (dial + rest >= 100)
			zero_count_p2 += full
			dial += rest
		case:
			panic("Unexpected input")
		}
		dial = (dial + 100) % 100
		zero_count_p1 += auto_cast (dial == 0)
	}

	fmt.printf("Part 1: %d\n", zero_count_p1)
	fmt.printf("Part 2: %d\n", zero_count_p2)
}
