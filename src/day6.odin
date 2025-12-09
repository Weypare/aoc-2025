package aoc_2025

import "core:bytes"
import "core:fmt"

day6 :: proc(input: []byte, _: bool) {
	part1(input)
	part2(input)
}

@(private = "file")
part1 :: proc(input_: []byte) {
	input := input_

	State :: struct {
		add_value: i64,
		mul_value: i64,
	}

	results: [dynamic]State
	defer delete(results)

	next_num :: proc(line: ^[]byte) -> i64 {
		trimmed := bytes.trim_left_space(line^)
		end_idx := bytes.index_byte(trimmed, ' ')
		num_slice: []byte
		if end_idx == -1 {
			num_slice = trimmed
			line^ = nil
		} else {
			num_slice = split_at(&trimmed, auto_cast end_idx)
			line^ = trimmed
		}
		assert(len(num_slice) > 0)
		return parse_i64_or_die(string(num_slice))
	}

	{
		line, ok := bytes.split_iterator(&input, []byte{'\n'})
		assert(ok, "there is a line")
		line = bytes.trim_right_space(line)

		for len(line) > 0 {
			n := next_num(&line)
			append(&results, State{n, n})
		}

	}

	op_line: []byte
	for line in bytes.split_iterator(&input, []byte{'\n'}) {
		l := bytes.trim_right_space(line)
		if len(l) == 0 {break}
		if l[0] == '*' || l[0] == '+' {op_line = l; break}

		for i := 0; len(l) > 0; i += 1 {
			n := next_num(&l)
			results[i].add_value += n
			results[i].mul_value *= n
		}
	}

	total: i64 = 0
	for i := 0;; i += 1 {
		op_line = bytes.trim_left_space(op_line)
		if len(op_line) == 0 {break}

		op := split_at(&op_line, 1)

		s := results[i]
		switch op[0] {
		case '+':
			total += s.add_value
		case '*':
			total += s.mul_value
		case:
			fmt.printf("Got invalid op: '%c'", op[0])
			assert(false, "invalid op")
		}
	}

	fmt.printf("Part 1: %d\n", total)
}

@(private = "file")
part2 :: proc(input_: []byte) {
	input := input_

	width: i64 = auto_cast bytes.index_byte(input, '\n')
	stride := width + 1

	height: i64 = 0
	op_line: []byte
	for line in bytes.split_iterator(&input, []byte{'\n'}) {
		if line[0] == '*' || line[0] == '+' {op_line = line; break}
		height += 1
	}

	number_grid := Grid {
		width  = width,
		height = height,
		stride = stride,
		inner  = input_,
	}

	Op :: enum {
		Add,
		Mul,
	}

	ColumnInfo :: struct {
		width: i64,
		op:    Op,
	}

	columns: [dynamic]ColumnInfo
	defer delete(columns)
	for len(op_line) > 0 {
		op: Op
		switch op_line[0] {
		case '+':
			op = .Add
		case '*':
			op = .Mul
		case:
			fmt.printf("Got invalid op: '%c' '%s'", op_line[0], op_line)
			assert(false, "invalid op")

		}
		end_idx := bytes.index_any(op_line[1:], []byte{'+', '*'})
		column_width: i64
		if end_idx == -1 {
			column_width = auto_cast len(op_line)
			op_line = nil
		} else {
			column_width = cast(i64)end_idx + 1 - 1
			split_at(&op_line, auto_cast end_idx + 1)
		}
		append(&columns, ColumnInfo{width = auto_cast column_width, op = op})
	}

	total: i64 = 0
	offset: i64 = 0
	for col in columns {
		defer offset += col.width + 1
		inner := number_grid.inner[offset:]
		subgrid := Grid {
			inner  = inner,
			stride = number_grid.stride,
			width  = col.width,
			height = number_grid.height,
		}

		col_total: i64
		col_proc: proc(_: i64, _: i64) -> i64

		switch col.op {
		case .Add:
			col_total = 0
			col_proc = proc(a: i64, b: i64) -> i64 {return a + b}
		case .Mul:
			col_total = 1
			col_proc = proc(a: i64, b: i64) -> i64 {return a * b}
		}

		for c := subgrid.width - 1; c >= 0; c -= 1 {
			n: i64 = 0
			in_number := false
			for r in 0 ..< subgrid.height {
				cell := grid_at(subgrid, r, c)
				assert(cell != nil)
				if cell^ == ' ' {
					if in_number {break} else {continue}
				}
				n *= 10
				n += auto_cast (cell^ - '0')
			}
			col_total = col_proc(col_total, n)
		}

		total += col_total
	}

	fmt.printf("Part 2: %d\n", total)
}

@(private = "file")
split_at :: proc(s: ^[]byte, mid: uint) -> []byte {
	prefix := s^[:mid]
	s^ = s[mid:]
	return prefix
}
