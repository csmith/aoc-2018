import sequtils, strutils

type
    GroundType = enum
        gtVoid, gtOpen, gtTrees, gtLumberYard
    Ground = array[-1..50, array[-1..50, GroundType]]

iterator around(x, y: int): tuple[x,y: int] =
    for i in -1..1:
        for j in -1..1:
            if i != 0 or j != 0:
                yield (x + i, y + j)

func hasAtLeastThree(ground: Ground, groundType: GroundType, x,y: int): bool =
    var count = 0
    for point in around(x, y):
        if ground[point.y][point.x] == groundType:
            count.inc
            if count == 3:
                return true
    return false

func resourceValue(ground: Ground): int =
    # Multiplying the number of wooded acres by the number of lumberyards gives
    # the total resource value 
    var trees, yards: int
    for row in ground:
        for cell in row:
            if cell == gtLumberYard:
                yards.inc
            elif cell == gtTrees:
                trees.inc
    trees * yards

func turnToTrees(ground: Ground, x,y: int): bool =
    # An open acre will become filled with trees if three or more adjacent
    # acres contained trees.
    ground.hasAtLeastThree(gtTrees, x, y)

func turnToLumberYard(ground: Ground, x,y: int): bool =
    # An acre filled with trees will become a lumberyard if three or more
    # adjacent acres were lumberyards.
    ground.hasAtLeastThree(gtLumberYard, x, y)

func remainLumberYard(ground: Ground, x,y: int): bool =
    # An acre containing a lumberyard will remain a lumberyard if it was
    # adjacent to at least one other lumberyard and at least one acre
    # containing trees. 
    var foundYard, foundTrees: bool
    for point in around(x,y):
        if ground[point.y][point.x] == gtLumberYard:
            foundYard = true
        if ground[point.y][point.x] == gtTrees:
            foundTrees = true
        if foundTrees and foundYard:
            return true
    return false

proc load(dest: var Ground) =
    var y: int
    for line in readFile("data/18.txt").strip.splitlines:
        for x, c in line:
            dest[y][x] = case c:
                of '.': gtOpen
                of '|': gtTrees
                of '#': gtLumberYard
                else: gtVoid
        y.inc

proc step(source: Ground, dest: var Ground) =
    for y, row in source:
        for x, cell in row:
            dest[y][x] = case cell:
                of gtVoid: gtVoid
                of gtOpen:
                    if source.turnToTrees(x, y):
                        gtTrees
                    else:
                        gtOpen
                of gtTrees:
                    if source.turnToLumberYard(x, y):
                        gtLumberYard
                    else:
                        gtTrees
                of gtLumberYard:
                    if source.remainLumberYard(x, y):
                        gtLumberYard
                    else:
                        gtOpen

const loops = 1_000_000_000

var
    grounds: array[100, Ground] # Arbitrary guess for maximum loop size
    activeGround, t: int

grounds[0].load

while t < loops:
    t.inc
    
    let nextGround = (activeGround + 1) mod grounds.len
    grounds[activeGround].step(grounds[nextGround])
    activeGround = nextGround
    
    if t == 10:
        echo grounds[activeGround].resourceValue
    
    # This isn't solvable by brute force, so assume that at some point the
    # state will repeat itself. If we find a loop, just jump the time ahead
    # by as many loops as we can, and carry on evaluating for the last few.
    for i, o in grounds:
        if i != activeGround and o == grounds[activeGround]:
            let
                loopLength = (grounds.len + activeGround - i) mod grounds.len
                remaining = (loops - t) mod loopLength
            t = loops
            activeGround = (i + remaining) mod grounds.len
            break

echo grounds[activeGround].resourceValue