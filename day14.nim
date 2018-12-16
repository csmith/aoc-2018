import sequtils, strutils

let
    input = readFile("data/14.txt").strip
    inputSeq = input.map do (c: char) -> int8: cast[int8](c.int - '0'.int)
    inputInt = input.parseInt
    inputLen = input.len

var
    scores: array[50_000_000, int8]  # Arbitrary large preallocation
    size = 2
    elf1 = 0
    elf2 = 1
    part2 = -1

proc check(inputSeq: seq[int8], val: int, part2: var int) {.inline.} =
    var found {.global.} = 0
    if val == inputSeq[found]:
        found.inc
        if found == inputLen:
            part2 = size - inputLen
            found = 0
    else:
        found = 0

scores[0] = 3
scores[1] = 7

while size < inputInt + 10 or part2 == -1:
    var score = scores[elf1] + scores[elf2]
    
    if score >= 10:
        scores[size] = 1
        size.inc
        inputSeq.check(1, part2)

    let newScore = cast[int8](score mod 10)
    scores[size] = newScore
    size.inc

    inputSeq.check(newScore, part2)

    elf1 = (elf1 + scores[elf1] + 1) mod size
    elf2 = (elf2 + scores[elf2] + 1) mod size

echo scores[inputInt..inputInt+9].join
echo part2