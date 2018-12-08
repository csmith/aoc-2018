import intsets, sequtils, strscans, strutils

var
    claims: seq[tuple[id, x, y, width, height: int]]
    max_x, max_y = int.low
    min_x, min_y = int.high

for line in readFile("data/03.txt").strip.splitlines:
    var id, x, y, width, height: int
    if not line.scanf("#$i @ $i,$i: $ix$i", id, x, y, width, height):
        raise newException(Defect,  "Invalid input line: " & line)
    claims.add((id, x, y, width, height))
    min_x = min(min_x, x)
    max_x = max(max_x, x + width)
    min_y = min(min_y, y)
    max_y = max(max_y, y + height)

let
    x_range = 1 + max_x - min_x
    y_range = 1 + max_y - min_y

var
    cells = newSeq[int](x_range * y_range)
    ids = initIntSet()
    overlaps = 0

for claim in claims:
    var collision = false
    for x in claim.x..claim.x + claim.width - 1:
        for y in claim.y..claim.y + claim.height - 1:
            var
                index = (y - min_y) * y_range + (x - min_x)
                previous = cells[index]
            if previous == 0:
                cells[index] = claim.id
            elif previous == -1:
                collision = true
            else:
                collision = true
                overlaps.inc
                if previous in ids:
                    ids.excl(previous)
                cells[index] = -1
    if not collision:
        ids.incl(claim.id)

echo overlaps
echo toSeq(ids.items)[0]
