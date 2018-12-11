import math, sequtils, strscans, strutils

# Expected height of our letters
const LetterHeight = 10

type
    Point = ref object
        sx, sy, x, y, dx, dy: int

var
    points: seq[Point]
    miny = int.high
    maxy = int.low
    mindy, maxdy = 0

for line in readFile("data/10.txt").strip.splitlines:
    var point = new(Point)
    if not line.scanf("position=<$s$i,$s$i> velocity=<$s$i,$s$i>", point.sx, point.sy, point.dx, point.dy):
        raise newException(Defect,  "Invalid input line: " & line)
    if point.sy < miny:
        miny = point.sy
        mindy = point.dy
    if point.sy > maxy:
        maxy = point.sy
        maxdy = point.dy
    points.add(point)

# Compute the first time at which the most outlying stars will be within
# letter-height of each other. It may take a few more iterations after
# this for them to get into their final place.
var t = (maxy - miny - LetterHeight) div (mindy - maxdy)

while true:
    var
        minx = int.high
        maxx = int.low
        miny = int.high
        maxy = int.low
    for point in points:
        point.x = point.sx + point.dx * t
        point.y = point.sy + point.dy * t
        minx = min(minx, point.x)
        maxx = max(maxx, point.x)
        miny = min(miny, point.y)
        maxy = max(maxy, point.y)

    if maxy - miny == LetterHeight - 1:
        for y in miny..maxy:
            var grid = newSeq[bool](1 + maxx - minx)
            for point in points:
                if point.y == y:
                    grid[point.x - minx] = true
            echo grid.map(proc(cell: bool): string =
                if cell:
                    "█"
                else:
                    " ").join
        echo t
        break
    
    t.inc
