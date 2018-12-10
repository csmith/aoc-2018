import math, sequtils, strscans, strutils

type
    Point = ref object
        x, y, dx, dy: int

var points: seq[Point]

for line in readFile("data/10.txt").strip.splitlines:
    var point = new(Point)
    if not line.scanf("position=<$s$i,$s$i> velocity=<$s$i,$s$i>", point.x, point.y, point.dx, point.dy):
        raise newException(Defect,  "Invalid input line: " & line)
    points.add(point)

var
    t = 0
    last_distance = int.high
while true:
    var
        minx = int.high
        maxx = int.low
        miny = int.high
        maxy = int.low
    for point in points:
        point.x += point.dx
        point.y += point.dy
        minx = min(minx, point.x)
        maxx = max(maxx, point.x)
        miny = min(miny, point.y)
        maxy = max(maxy, point.y)

    var distance = (maxx - minx) * (maxy - miny)
    if distance > last_distance:
        for y in miny..maxy:
            var grid = newSeq[bool](1 + maxx - minx)
            for point in points:
                if point.y - point.dy == y:
                    grid[point.x - point.dx - minx] = true
            echo grid.map(proc(cell: bool): string =
                if cell:
                    "█"
                else:
                    " ").join
        echo t
        break
    else:
        last_distance = distance
        t.inc
