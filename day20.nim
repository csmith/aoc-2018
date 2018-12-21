import deques, sequtils, sets, strutils, tables

type
    Point = tuple[x,y: int]

    Direction = enum
        N, E, S, W

    Sequence = ref object
        forks: bool
        nodes: seq[Sequence]
        content: seq[Direction]

proc `+` (a, b: Point): Point =
    result.x = a.x + b.x
    result.y = a.y + b.y

# Parses the regular expression into a 'Sequence' data structure, by pushing
# sequences onto a stack each time a nested expression is encountered.
#
# Three types of sequences are found:
#  1) "Content-only", e.g. NNNEEE
#  2) "Forks", e.g. (subsequence|subsequence|subsequence)
#  3) "Concatenations", e.g. NN(subsequence)EE
#
func process(regex: string): Sequence =
    var
        stack = initDeque[Sequence]()
        span: seq[Direction]
    result = new(Sequence)
    stack.addLast(result)
    
    for c in regex:
        if c == '^':
            continue
        
        if c in ['(', ')', '|', '$']:
            if span.len > 0:
                # If we've got bare directions, add them as a content element.
                var newSeq = new(Sequence)
                newSeq.content = span
                stack.peekLast.nodes.add(newSeq)
                span.setLen(0)
            if c == '(':
                # To start a new fork block we add two sequences: one that will
                # contain all the forked elements, and the first child to hold
                # the content of the first fork.
                var forkSeq = new(Sequence)
                forkSeq.forks = true
                stack.addLast(forkSeq)
                stack.addLast(new(Sequence))
            elif c == '|':
                # Pop the previous child off and add it to the parent fork block,
                # then add a new one for the next branch.
                var child = stack.popLast
                stack.peekLast.nodes.add(child)
                stack.addLast(new(Sequence))
            elif c == ')':
                # Pop both the child and the parent fork block off the stack.
                var child = stack.popLast
                stack.peekLast.nodes.add(child)
                var forkSeq = stack.popLast
                stack.peekLast.nodes.add(forkSeq)
        else:
            span.add(parseEnum[Direction]($c))

    stack.popLast

let
    directions = {
        N: ( 0,  1),
        E: ( 1,  0),
        S: ( 0, -1),
        W: (-1,  0),
    }.toTable
    opposites = { N: S, E: W, S: N, W: E, }.toTable
    input = readFile("data/20.txt").strip

proc addDirection(table: var Table[Point, HashSet[Direction]], point: Point, direction: Direction) =
    if not table.hasKey(point):
        table[point] = initSet[Direction]()
    table[point].incl(direction)

proc addDirections(table: var Table[Point, HashSet[Direction]], point: Point, direction: Direction): Point =
    let otherPoint = point + directions[direction]
    table.addDirection(point, direction)
    table.addDirection(otherPoint, opposites[direction])
    otherPoint

# Recurses through the given sequence and builds up a map of which points are
# traversable in which directions.
#
# The points parameter tracks which points could have been reached by the
# sequence thus far. The current sequence must be evaluated for all of those
# points. Initially this is just {(0,0)} but every time a fork is encountered
# the number of points will expand.
proc map(sequence: Sequence, grid: var Table[Point, HashSet[Direction]], points: HashSet[Point]): HashSet[Point] =
    if sequence.content.len > 0:
        result = initSet[Point]()
        for point in points:
            var newPoint = point
            for d in sequence.content:
                newPoint = grid.addDirections(newPoint, d)
            result.incl(newPoint)
    elif sequence.forks:
        result = initSet[Point]()
        for child in sequence.nodes:
            result.incl(child.map(grid, points))
    else:
        result = points
        for child in sequence.nodes:
            result = child.map(grid, result)

# Performs a breadth-first search of the navigable area and assigns a
# distance to each point.
proc score(dirs: Table[Point, HashSet[Direction]]): Table[Point, int] =
    result = initTable[Point, int]()
    var stack = initDeque[tuple[pos: Point, length: int]]()
    stack.addLast(((0, 0), 0))
    while stack.len > 0:
        let step = stack.popFirst
        if not result.hasKey(step.pos) or result[step.pos] > step.length:
            result[step.pos] = step.length
            for direction in dirs[step.pos]:
                stack.addLast((step.pos + directions[direction], step.length + 1))

proc distances(input: string): seq[int] =
    var grid = initTable[Point, HashSet[Direction]]()
    let points = toSet([(0, 0)])
    discard input.process.map(grid, points)
    toSeq(grid.score.values)

let distanceValues = input.distances
echo distanceValues.max
echo distanceValues.filter(proc(i: int): bool = i >= 1000).len