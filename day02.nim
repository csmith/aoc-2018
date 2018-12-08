import sequtils, strutils

proc checksum(ids: seq[string]): int =
    var pairCount, tripCount: int
    for id in ids:
        var pairs, trips: bool
        for c in id:
            var count = id.count(c)
            if count == 2 and not pairs:
                pairs = true
                pairCount.inc
            if count == 3 and not trips:
                trips = true
                tripCount.inc
            if pairs and trips:
                break
    pairCount * tripCount

proc difference(pairs: seq[tuple[a: char, b: char]]): string =
    var difference: bool
    for pair in pairs:
        if pair.a != pair.b:
            if difference:
                return ""
            else:
                difference = true
        else:
            result &= pair.a

proc max_common(ids: seq[string]): string =
    for i, id1 in ids:
        for id2 in ids[i+1 .. ids.high]:
            let difference = zip(id1, id2).difference
            if difference != "":
                return difference
    

let ids = readFile("data/02.txt").strip.splitlines
echo ids.checksum
echo ids.max_common