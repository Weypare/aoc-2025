package aoc_2025

import "core:bytes"
import "core:fmt"

day3 :: proc(input_: []byte) {
	input := input_

	sum_p1: i64 = 0
	sum_p2: i64 = 0
	for bank in bytes.split_iterator(&input, []byte{'\n'}) {
		if len(bank) == 0 {continue}
		assert(len(bank) >= 2)

		buf_p1: [2]byte
		impl(bank, buf_p1[:], &sum_p1)
		buf_p2: [12]byte
		impl(bank, buf_p2[:], &sum_p2)
	}

	fmt.printf("Part 1: %d\n", sum_p1)
	fmt.printf("Part 2: %d\n", sum_p2)
}

@(private = "file")
impl :: proc(bank: []byte, buf: []byte, sum: ^i64) {
	assert(len(bank) >= len(buf))
	for i in 0 ..< len(buf) {
		buf[len(buf) - 1 - i] = bank[len(bank) - 1 - i]
	}

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

	sum^ += joltage
}
