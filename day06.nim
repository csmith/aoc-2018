import math, sequtils, strutils

type
    Point = array[2, int]

func read_coords(text: string): seq[Point] =
    for line in text.strip.splitlines:
        let parts = line.split(", ").map(parseInt)
        result &= [parts[0], parts[1]]

func bounds(coords: seq[Point]): array[4, int] =
    let
        xs = coords.map(proc(coord: Point): int = coord[0])
        ys = coords.map(proc(coord: Point): int = coord[1])
    result = [min(xs), max(xs), min(ys), max(ys)]

func distance(point1: Point, point2: Point): int =
    abs(point1[0] - point2[0]) + abs(point1[1] - point2[1])

func nearest(coords: seq[Point], point: Point): int =
    let
        distances = coords.map(proc(coord: Point): int = coord.distance(point))
        lowest = min(distances)
        lowest_count = distances.filter(proc (distance: int): bool = distance == lowest).len
    if lowest_count == 1:
        distances.find(lowest)
    else:
        -1

func inrange(coords: seq[Point], point: Point): bool = coords.map(proc (coord: Point): int =
    coord.distance(point)).sum < 10000

func part1(coords: seq[Point], extents: array[4, int]): int =
    var
        counts = newSeqWith(coords.len, 0)
        excluded = newSeqWith(coords.len, false)

    for x in extents[0] .. extents[1]:
        for y in extents[2] .. extents[3]:
            let coord = coords.nearest([x, y])
            if coord != -1:
                counts[coord].inc
                
                # If the area reaches the edge of the grid, it will continue infinitely.
                # Mark that area as excluded.
                if x == extents[0] or x == extents[1] or y == extents[2] or y == extents[3]:
                    excluded[coord] = true

    zip(counts, excluded)
            .filter(proc(x: tuple[a: int, b: bool]): bool = not x.b)
            .map(proc(x: tuple[a: int, b: bool]): int = x.a)
            .max

func part2(coords: seq[Point], extents: array[4, int]): int =
    var
        size = 0
        found = false
    let
        extension = int(10000 / coords.len)
        y_start = extents[2] - extension
        y_finish = extents[3] + extension
        y_range = y_finish - y_start

    # The region we're in is going to be contiguous so once we've found some
    # 'safe' areas and subsequently hit a row/column with none in, we can abort
    for x in extents[0] - extension .. extents[1] + extension:
        var
            min_y = int.high
            max_y = int.high

        for y in extents[2] - extension .. extents[3] + extension:
            if coords.inrange([x,y]):
                if min_y == int.high:
                    min_y = y
                max_y = y
            elif max_y != int.high:
                break
        
        if min_y != int.high:
            size += abs(max_y - min_y) + 1
            found = true
        elif found:
            break

    size

let
    coords = read_coords(readFile("data/06.txt"))
    extents = coords.bounds

echo part1(coords, extents)
echo part2(coords, extents)