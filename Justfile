exe_file := "build/aoc_2025"

_all:
    @just --list

build-debug:
    @mkdir -p build
    odin build src -out:{{exe_file}} -vet -debug -o:none

build:
    @mkdir -p build
    odin build src -out:{{exe_file}} -vet

run day: build
    {{exe_file}} {{day}}

run-example day: build
    {{exe_file}} {{day}} --example

new-day day:
    touch src/day{{day}}.odin inputs/{{day}}.example.txt inputs/{{day}}.txt
