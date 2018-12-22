import sequtils, strutils, tables

type
    Point = tuple[x,y: int]
    Tool = enum tTorch, tClimbing, tNeither
    Node = tuple[pos: Point, tool: Tool]

iterator moves(point: Point): Point =
    let (x, y) = point
    
    if y > 0: yield (x, y - 1)
    if x > 0: yield (x - 1, y)
    yield (x, y + 1)
    yield (x + 1, y)

let
    input = readFile("data/22.txt").splitLines
    depth = input[0].strip.split(' ')[1].parseInt
    targetParts = input[1].strip.split(' ')[1].split(',').map(parseInt)
    target: Point = (targetParts[0], targetParts[1])
    targetNode: Node = (target, tTorch)
    tools = [[tClimbing, tTorch], [tClimbing, tNeither], [tTorch, tNeither]]

var
    erosions = initTable[Point, int]()
    dangerSum = 0

# Add arbitrary extension to allow for a bit of overshooting.
for y in 0..target.y + 75:
    for x in 0..target.x + 75:
        let
            geoindex = if (x == 0 and y == 0) or (x, y) == target:
                    0
                elif y == 0:
                    x * 16807
                elif x == 0:
                    y * 48271
                else:
                    erosions[(x-1, y)] * erosions[(x, y-1)]
            erosionlevel = (geoindex + depth) mod 20183
        
        erosions[(x, y)] = erosionlevel
        if x <= target.x and y <= target.y:
            dangerSum += erosionlevel mod 3

# Custom stack of pending steps, kept in order from smallest to largest.
# Insertion is O(n), removing the smallest is O(1). Performs approximately a
# billionty times faster than I managed using a Seq/Deque/Table/CountingTable.
type
    StackStep = ref object
        node: Node
        distance: int
        next: StackStep
    
    Stack = object
        head: StackStep

proc insert(stack: var Stack, node: Node, distance: int) =
    var newNode = new(StackStep)
    newNode.node = node
    newNode.distance = distance

    if stack.head == nil:
        stack.head = newNode
    else:
        var target = stack.head
        while target.next != nil and target.next.distance < distance:
            target = target.next
        newNode.next = target.next
        target.next = newNode

proc popSmallest(stack: var Stack): tuple[node: Node, distance: int] =
    result = (stack.head.node, stack.head.distance)
    stack.head = stack.head.next

var
    distances = initTable[Node, int]()
    stack: Stack

stack.insert(((0, 0), tTorch), 0)

while not distances.hasKey(targetNode):
    let (node, distance) = stack.popSmallest

    # We can have duplicate steps in our stack, but if we've already
    # put the distance then that route was necessarily shorter. Just
    # skip it.
    if distances.hasKey(node):
        continue
    
    distances[node] = distance

    # At each node we can switch tools once, with a cost of 7 minutes
    for tool in tools[erosions[node.pos] mod 3]:
        if tool != node.tool and not distances.hasKey((node.pos, tool)):
            stack.insert(((node.pos, tool)), distance + 7)

    # Up to four possible moves from the current node, depending on
    # terrain and tools.
    for newPos in node.pos.moves:
        if erosions.hasKey(newPos) and
                node.tool in tools[erosions[newPos] mod 3] and
                not distances.hasKey((newPos, node.tool)):
            stack.insert(((newPos, node.tool)), distance + 1)

echo dangerSum
echo distances[targetNode]
