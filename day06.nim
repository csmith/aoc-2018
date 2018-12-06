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

func distance(point1: Point, point2: Point): int = abs(point1[0] - point2[0]) + abs(point1[1] - point2[1])

func nearest(coords: seq[Point], point: Point): int =
    var
        min = -1
        best = -1
        dupe = false
        i = 0

    for coord in coords:
        let distance = coord.distance(point)
        if min == -1 or distance < min:
            min = distance
            best = i
            dupe = false
        elif min == distance:
            dupe = true
        i += 1
    
    if dupe:
        result = -1
    else:
        result = best

func inrange(coords: seq[Point], point: Point): bool = coords.map(proc (coord: Point): int = coord.distance(point)).sum < 10000

let
    coords = read_coords(readFile("data/06.txt"))
    extents = coords.bounds

var
    counts = newSeqWith(coords.len, 0)
    excluded = newSeqWith(coords.len, false)

for x in extents[0] .. extents[1]:
    for y in extents[2] .. extents[3]:
        let coord = coords.nearest([x, y])
        if coord != -1:
            counts[coord] += 1
            if x == extents[0] or x == extents[1] or y == extents[2] or y == extents[3]:
                excluded[coord] = true

echo zip(counts, excluded)
        .filter(proc(x: tuple[a: int, b: bool]): bool = not x.b)
        .map(proc(x: tuple[a: int, b: bool]): int = x.a)
        .max


var size = 0
let
    extension = int(10000 / coords.len)
    y_start = extents[2] - extension
    y_finish = extents[3] + extension
    y_range = y_finish - y_start

for x in extents[0] - extension .. extents[1] + extension:
    var
        min_y = 0
        max_y = 0
    for y in extents[2] - extension .. extents[3] + extension:
        if coords.inrange([x,y]):
            min_y = y
            break
    for dy in 0 .. y_range:
        var y = y_finish - dy
        if coords.inrange([x,y]):
            max_y = y + 1
            break
    size += abs(max_y - min_y)

echo size