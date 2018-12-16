import sequtils, strutils

let
    input = readFile("data/14.txt").strip
    inputSeq = input.map do (c: char) -> int8: cast[int8](c.int - '0'.int)
    inputInt = input.parseInt
    inputLen = input.len

var
    scores = @[3'i8, 7'i8]
    elf1 = 0
    elf2 = 1
    part2 = -1

proc check(inputSeq: seq[int8], val: int, part2: var int) {.inline.} =
    var found {.global.} = 0
    if val == inputSeq[found]:
        found.inc
        if found == inputLen:
            part2 = scores.len - inputLen
            found = 0
    else:
        found = 0

while scores.len < inputInt + 10 or part2 == -1:
    var score = scores[elf1] + scores[elf2]
    
    if score >= 10:
        scores.add(1)
        inputSeq.check(1, part2)

    let newScore = cast[int8](score mod 10)
    scores.add(newScore)

    inputSeq.check(newScore, part2)

    elf1 = (elf1 + scores[elf1] + 1) mod scores.len
    elf2 = (elf2 + scores[elf2] + 1) mod scores.len

echo scores[inputInt..inputInt+9].join
echo part2