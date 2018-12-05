import intsets, math, sequtils, strutils

let input = readFile("data/01.txt").splitLines.map(parseInt)

proc part1(freqs: seq[int]): int =
    freqs.sum

proc part2(freqs: seq[int]): int =
    var seen = initIntSet()
    var talley: int

    while true:
        for n in freqs:
            talley += n
            if talley in seen:
                return talley
            seen.incl(talley)

echo part1(input)
echo part2(input)
