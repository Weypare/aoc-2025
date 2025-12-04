package aoc_2025

import "core:bytes"
import "core:fmt"

day3 :: proc(input_: []byte) {
	input := input_

	sum_p1: i64 = 0
	sum_p2: i64 = 0
	for bank in bytes.split_iterator(&input, []byte{'\n'}) {
		if len(bank) == 0 {continue}
		sum_p1 += impl(2, bank)
		sum_p2 += impl(12, bank)
	}

	fmt.printf("Part 1: %d\n", sum_p1)
	fmt.printf("Part 2: %d\n", sum_p2)
}

@(private = "file")
impl :: proc($N: int, bank: []byte) -> i64 {
	assert(len(bank) >= N)
	buf: [N]byte
	copy(buf[:], bank[len(bank)-len(buf):])

	for i := len(bank) - 1 - len(buf); i >= 0; i -= 1 {
		candidate := bank[i]
		for j in 0 ..< len(buf) {
			item := buf[j]
			if item > candidate {break}
			buf[j] = candidate
			candidate = item
		}
	}

	joltage: i64 = 0
	for i in buf {
		joltage *= 10
		joltage += cast(i64)(i - '0')
	}

	return joltage
}
