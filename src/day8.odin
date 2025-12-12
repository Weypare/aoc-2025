package aoc_2025

import "core:bytes"
import "core:fmt"
import "core:slice"

@(private = "file")
Vec3 :: [3]f32

day8 :: proc(input_: []byte, is_example: bool) {
	input := input_

	boxes: [dynamic]Vec3
	defer delete(boxes)

	for line in bytes.split_iterator(&input, []byte{'\n'}) {
		if len(line) == 0 {continue}
		l := line
		x, _ := bytes.split_iterator(&l, []byte{','})
		y, _ := bytes.split_iterator(&l, []byte{','})
		z := l
		append(
			&boxes,
			Vec3 {
				cast(f32)parse_i64_or_die(string(x)),
				cast(f32)parse_i64_or_die(string(y)),
				cast(f32)parse_i64_or_die(string(z)),
			},
		)
	}

	part1(boxes[:], is_example)
	part2(boxes[:])
}

@(private = "file")
part1 :: proc(boxes: []Vec3, is_example: bool) {
	MinDistance :: struct {
		from: Vec3,
		to:   Vec3,
		dist: f32,
	}

	all_box_distances: [dynamic]MinDistance
	defer delete(all_box_distances)

	for from, i in boxes {
		for to in boxes[i + 1:] {
			dist := squared_distance(from, to)
			append(&all_box_distances, MinDistance{from = from, to = to, dist = dist})
		}
	}

	slice.sort_by_key(all_box_distances[:], proc(x: MinDistance) -> f32 {return x.dist})

	Circuit :: struct {
		members: [dynamic]Vec3,
	}

	is_in_circuit_map: map[Vec3]int
	defer delete(is_in_circuit_map)
	circuit_state_map: map[int]Circuit
	defer {
		for _, &v in circuit_state_map {
			delete(v.members)
		}
		delete(circuit_state_map)
	}

	next_circuit_id := 0
	remaining_connections := is_example ? 10 : 1000
	for i in all_box_distances {
		if remaining_connections <= 0 {break}

		c1_id, c1_found := is_in_circuit_map[i.from]
		c2_id, c2_found := is_in_circuit_map[i.to]

		defer remaining_connections -= 1

		if c1_found && c2_found && c1_id == c2_id {
			continue
		}

		if c1_found && c2_found {
			defer delete_key(&circuit_state_map, c2_id)
			c1_state := &circuit_state_map[c1_id]
			c2_state := &circuit_state_map[c2_id]

			defer delete(c2_state.members)
			for box in c2_state.members {
				append(&c1_state.members, box)
				is_in_circuit_map[box] = c1_id
			}

			continue
		}

		if c1_found {
			is_in_circuit_map[i.to] = c1_id
			c_state := &circuit_state_map[c1_id]
			append(&c_state.members, i.to)
			continue
		}

		if c2_found {
			is_in_circuit_map[i.from] = c2_id
			c_state := &circuit_state_map[c2_id]
			append(&c_state.members, i.from)
			continue
		}

		defer next_circuit_id += 1
		is_in_circuit_map[i.from] = next_circuit_id
		is_in_circuit_map[i.to] = next_circuit_id
		members: [dynamic]Vec3
		append(&members, i.from)
		append(&members, i.to)
		circuit_state_map[next_circuit_id] = Circuit{members}
	}

	sizes: [dynamic]int
	defer delete(sizes)
	for _, &value in circuit_state_map {
		append(&sizes, len(value.members))
	}
	slice.reverse_sort(sizes[:])

	assert(len(sizes) >= 3)
	result := sizes[0] * sizes[1] * sizes[2]

	fmt.printfln("Part 1: %d", result)
}

@(private = "file")
part2 :: proc(boxes: []Vec3) {
	MinDistance :: struct {
		from: Vec3,
		to:   Vec3,
		dist: f32,
	}

	all_box_distances: [dynamic]MinDistance
	defer delete(all_box_distances)

	for from, i in boxes {
		for to in boxes[i + 1:] {
			dist := squared_distance(from, to)
			append(&all_box_distances, MinDistance{from = from, to = to, dist = dist})
		}
	}

	slice.sort_by_key(all_box_distances[:], proc(x: MinDistance) -> f32 {return x.dist})

	Circuit :: struct {
		members: [dynamic]Vec3,
	}

	is_in_circuit_map: map[Vec3]int
	defer delete(is_in_circuit_map)
	circuit_state_map: map[int]Circuit
	defer {
		for _, &v in circuit_state_map {
			delete(v.members)
		}
		delete(circuit_state_map)
	}

	last_connnect: [2]Vec3
	next_circuit_id := 0

	for i in all_box_distances {
		if len(circuit_state_map) == 1 {
			for _, &v in circuit_state_map {
				if len(v.members) == len(boxes) {
					break
				}
			}
		}

		c1_id, c1_found := is_in_circuit_map[i.from]
		c2_id, c2_found := is_in_circuit_map[i.to]

		if c1_found && c2_found && c1_id == c2_id {
			continue
		}

		last_connnect = [2]Vec3{i.from, i.to}

		if c1_found && c2_found {
			defer delete_key(&circuit_state_map, c2_id)
			c1_state := &circuit_state_map[c1_id]
			c2_state := &circuit_state_map[c2_id]

			defer delete(c2_state.members)
			for box in c2_state.members {
				append(&c1_state.members, box)
				is_in_circuit_map[box] = c1_id
			}

			continue
		}

		if c1_found {
			is_in_circuit_map[i.to] = c1_id
			c_state := &circuit_state_map[c1_id]
			append(&c_state.members, i.to)
			continue
		}

		if c2_found {
			is_in_circuit_map[i.from] = c2_id
			c_state := &circuit_state_map[c2_id]
			append(&c_state.members, i.from)
			continue
		}

		defer next_circuit_id += 1
		is_in_circuit_map[i.from] = next_circuit_id
		is_in_circuit_map[i.to] = next_circuit_id
		members: [dynamic]Vec3
		append(&members, i.from)
		append(&members, i.to)
		circuit_state_map[next_circuit_id] = Circuit{members}
	}

	fmt.printfln("Part 2: %d", cast(int)last_connnect[0][0] * cast(int)last_connnect[1][0])
}

@(private = "file")
squared_distance :: proc(a, b: [$N]f32) -> f32 {
	out: f32 = 0.0
	for _, i in a {
		v := a[i] - b[i]
		out += v * v
	}
	return out
}
