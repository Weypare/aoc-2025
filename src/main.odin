package aoc_2025

import "core:flags"
import "core:fmt"
import "core:os"

Cli :: struct {
	day:     u8 `args:"pos=0,required" usage:"Day to run."`,
	example: bool `usage:"Run example input."`,
}

main :: proc() {
	cli: Cli
	flags.parse_or_exit(&cli, os.args, .Unix)

	if cli.day == 0 || auto_cast cli.day > len(SOLUTIONS) {
		fmt.eprintf("Day must be in the range 1..=%d\n", len(SOLUTIONS))
		os.exit(1)
	}

	buf: [128]u8
	file_name := fmt.bprintf(buf[:], "./inputs/%d%s.txt", cli.day, cli.example ? ".example" : "")

	input, success := os.read_entire_file(file_name)
	assert(success, "input file exists")

	solution := SOLUTIONS[cli.day - 1]
	solution(input, cli.example)
}

SOLUTIONS: []proc(_: []byte, is_example: bool) = {
	day1,
	day2,
	day3,
	day4,
	day5,
	day6,
	day7,
	day8,
	day9,
	//
}
