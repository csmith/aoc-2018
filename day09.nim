import strscans

type
    Marble = object
        next, prev: ptr Marble
        value: int32

proc insertAfter(node: ptr Marble, value: int) {.inline.} =
    var newNode = cast[ptr Marble](alloc0(sizeof(Marble)))
    newNode.value = cast[int32](value)
    newNode.next = node.next
    newNode.prev = node
    newNode.next.prev = newNode
    newNode.prev.next = newNode

proc remove(node: ptr Marble) {.inline.} =
    node.prev.next = node.next
    node.next.prev = node.prev

proc newSingleNode(value: int): ptr Marble =
    result = cast[ptr Marble](alloc0(sizeof(Marble)))
    result.value = cast[int32](value)
    result.next = result
    result.prev = result

var
    input = readFile("data/09.txt")
    players: int
    marbles: int

if not input.scanf("$i players; last marble is worth $i points", players, marbles):
    raise newException(Defect,  "Invalid input line: " & input)

var
    player = 0
    scores = newSeq[int](players)
    current = newSingleNode(0)
    specialCountdown = 23
    hundredMarbles = marbles * 100

for i in 1 .. hundredMarbles:
    specialCountdown.dec
    if specialCountdown == 0:
        specialCountdown = 23
        player = (player + 23) mod players
        current = current.prev.prev.prev.prev.prev.prev.prev
        scores[player] += i + current.value
        current.remove
        current = current.next
    else:
        current.next.insertAfter(i)
        current = current.next.next

    if i == marbles or i == hundredMarbles:
        echo scores.max
