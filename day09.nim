import lists, strscans, strutils

func insertAfter(node: DoublyLinkedNode[int], value: int) =
    var newNode = newDoublyLinkedNode(value)
    newNode.next = node.next
    newNode.prev = node
    newNode.next.prev = newNode
    newNode.prev.next = newNode

func remove(node: DoublyLinkedNode[int]) =
    node.prev.next = node.next
    node.next.prev = node.prev

func newSingleNode(value: int): DoublyLinkedNode[int] =
    result = newDoublyLinkedNode(value)
    result.next = result
    result.prev = result

var
    input = readFile("data/09.txt").strip
    players: int
    marbles: int

if not input.scanf("$i players; last marble is worth $i points", players, marbles):
    raise newException(Defect,  "Invalid input line: " & input)

var
    player = 0
    scores = newSeq[int](players)
    current = newSingleNode(0)

for i in 1..marbles*100:
    if i mod 23 == 0:
        current = current.prev.prev.prev.prev.prev.prev.prev
        scores[player] += i + current.value
        current.remove
        current = current.next
    else:
        current.next.insertAfter(i)
        current = current.next.next

    player = (player + 1) mod players

    if i == marbles or i == marbles * 100:
        echo scores.max
