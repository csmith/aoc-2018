import strscans

# For performance, we only use pointers to Marbles (and manually allocate)
# memory required for them. This stops the GC tracking them, saving a fair
# chunk of time. Removed marbles will leak, but it doesn't really matter for
# the scope of this program.

type
    Marble = ptr object
        next: Marble
        value: int32

proc insertAfter(node: Marble, value: int) {.inline.} =
    var newNode = cast[Marble](alloc0(sizeof(Marble)))
    newNode.value = cast[int32](value)
    newNode.next = node.next
    node.next = newNode

proc removeNext(node: Marble) {.inline.} =
    node.next = node.next.next

proc newSingleNode(value: int): Marble =
    result = cast[Marble](alloc0(sizeof(Marble)))
    result.value = cast[int32](value)
    result.next = result

var
    input = readFile("data/09.txt")
    players: int
    marbles: int

if not input.scanf("$i players; last marble is worth $i points", players, marbles):
    raise newException(Defect,  "Invalid input line: " & input)

# Instead of using a doubly-linked list, we keep a current pointer and a
# separate one trailing behind it. The trail will expand to 8 marbles and is
# used when a multiple of 23 is played (so we can remove the N-7th marble). The
# trail then catches up to the current pointer and drifts back to 8 again over
# the next few moves. This saves a 64 bit memory allocation per marble, which
# gives a small but noticable speed bump.

var
    player = 0
    scores = newSeq[int](players)
    current = newSingleNode(0)
    currentTrail = current
    currentTrailDrift = 0
    specialCountdown = 23
    hundredMarbles = marbles * 100

for i in 1 .. hundredMarbles:
    # Instead of testing each marble number to see if it's a multiple of 23, we
    # keep a counter that we just loop over and over again.
    specialCountdown.dec
    if specialCountdown == 0:
        # The current player is only relevant when a 23nth marble is played, so
        # we can just update the player here instead of every turn.
        player = (player + 23) mod players
        scores[player] += i + currentTrail.next.value
        currentTrail.removeNext
        current = currentTrail.next
        currentTrail = current
        currentTrailDrift = 0
        specialCountdown = 23
    else:
        current.next.insertAfter(i)
        current = current.next.next
        if currentTrailDrift == 8:
            currentTrail = currentTrail.next.next
        else:
            currentTrailDrift += 2

    if i == marbles or i == hundredMarbles:
        echo scores.max
