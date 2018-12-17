import sequtils, strformat, strutils, tables

type
    Point = tuple[x,y: int]
    GroundType = enum
        gtSand, gtClay, gtStillWater, gtFlowingWater

var
    grid = newTable[Point, GroundType]()
    miny = int.high
    maxy = int.low

func down(point: Point): Point =
    (point.x, point.y + 1)

func isAt(grid: TableRef[Point, GroundType], gtype: GroundType, point: Point): bool =
    grid.getOrDefault(point, gtSand) == gtype

func supportsWater(grid: TableRef[Point, GroundType], point: Point): bool =
    let ground = grid.getOrDefault(point, gtSand)
    ground == gtClay or ground == gtStillWater

func countWater(grid: TableRef[Point, GroundType]): tuple[all,still: int] =
    for val in grid.values:
        if val == gtFlowingWater:
            result.all.inc
        if val == gtStillWater:
            result.all.inc
            result.still.inc

# Debug utility to print the grid nicely. Requires a small terminal font size.
proc print(grid: TableRef[Point, GroundType]) =
    for y in miny-1..maxy+1:
        var line = fmt "{y:4}  "
        for x in 300..700:
            case grid.getOrDefault((x, y), gtSand):
                of gtSand: line &= " "
                of gtClay: line &= "█"
                of gtStillWater: line &= "~"
                of gtFlowingWater: line &= "|"
        echo line
    echo ""

# These all call each other so we have to forward declare them
proc flowDown(grid: TableRef[Point, GroundType], point: Point): bool
proc flowOut(grid: TableRef[Point, GroundType], point: Point): bool
proc findEdge(grid: TableRef[Point, GroundType], point: Point, direction: int): tuple[enclosed: bool, last: int]

# flowDown() is responsible for recursively following a stream of water
# downwards until it hits something or surpasses the maximum y extent.
#
# The proc returns `true` if the downward flow has spread out (e.g.
# has filled in the bottom row of a "U" shaped area). If this happens
# the caller will also attempt to flow out to fill the next row.
proc flowDown(grid: TableRef[Point, GroundType], point: Point): bool =
    let
        next = point.down
        cell = grid.getOrDefault(next, gtSand)
    
    if point.y > maxy:
        return false

    if cell == gtSand:
        # There's nothing below us, keep flowing. Check to see if the flow
        # below is fills out, and if it does flow out on this row too;
        # otherwise, this is just a normal downward flow and we return false
        # as our parents don't need to flow out.
        if grid.flowDown(next):
            return grid.flowOut(point)
        else:
            grid[point] = gtFlowingWater
            return false

    elif cell == gtClay or cell == gtStillWater:
        # We've reached the bottom of a hole (or the existing water
        # level within a complex shape), flow outwards
        return grid.flowOut(point)

    elif cell == gtFlowingWater:
        # We've encountered some flowing water (i.e. we have a parallel
        # stream that has already flowed out below us). There's no need
        # to recheck anything, just join up with the other flow.
        grid[point] = gtFlowingWater
        return false

# flowOut() is responsible for expanding a flow of water horizontally
# after it hits something. It scans left and right to find the maximum
# extents, and whether or not they're enclosed.
#
# If both sides are enclosed then all the cells inbetween fill with
# still water, and we return true so that the row above us flows out.
#
# Sides that aren't enclosed are flowed down. In complex shapes these
# may fill up areas below them. Where either side fills up, we
# recursively call ourselves to deal with the new situation.
#
# Finally, in other cases the cells inbetween the extents become
# flowing water and we return false.
proc flowOut(grid: TableRef[Point, GroundType], point: Point): bool =
    let
        left = grid.findEdge(point, -1)
        right = grid.findEdge(point, 1)

    if left.enclosed and right.enclosed:
        # Both sides are enclosed, just fill'er up and make our
        # parent recalculate.
        for x in left.last..right.last:
            grid[(x, point.y)] = gtStillWater
        return true

    var leftFilled, rightFilled: bool

    if not left.enclosed:
        leftFilled = grid.flowDown((left.last, point.y + 1))
    if not right.enclosed:
        rightFilled = grid.flowDown((right.last, point.y + 1))
    
    if leftFilled or rightFilled:
        # We've filled in some holes and now our extents are no longer
        # valid. Recursively call ourselves to figure out what's what.
        return flowOut(grid, point)
    else:
        # We didn't fill anything, so this is the layer of flowing
        # water on top of a platform.
        for x in left.last..right.last:
            grid[(x, point.y)] = gtFlowingWater
        return false

proc findEdge(grid: TableRef[Point, GroundType], point: Point, direction: int): tuple[enclosed: bool, last: int] =
    var x = point.x
    while grid.supportsWater((x, point.y + 1)) and not grid.isAt(gtClay, (x + direction, point.y)):
        x += direction
    result.last = x
    result.enclosed = grid.getOrDefault((x + direction, point.y), gtSand) == gtClay

for line in readFile("data/17.txt").strip.splitlines:
    let
        parts = line.split(", ")
        first = parts[0].substr(2).parseInt
        numbers = parts[1].substr(2).split("..")
        isX = parts[1][0] == 'x'
    
    for i in numbers[0].parseInt..numbers[1].parseInt:
        var x,y: int
        if isX:
            x = i
            y = first
        else:
            x = first
            y = i

        grid[(x, y)] = gtClay
        miny = min(miny, y)
        maxy = max(maxy, y)

discard grid.flowDown((500, miny))

# grid.print()

let result = grid.countWater
echo result.all
echo result.still