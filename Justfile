build:
    @mkdir -p build
    odin build src -out:build/aoc_2025

run: build
    build/aoc_2025
