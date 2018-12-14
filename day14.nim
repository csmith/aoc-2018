import sequtils, strutils

let
    input = readFile("data/14.txt").strip
    inputSeq = input.map do (c: char) -> int8: cast[int8](c.int - '0'.int)
    inputHead = inputSeq[0..inputSeq.len-2]
    lastDigit = inputSeq[inputSeq.len - 1]
    inputInt = input.parseInt

var
    scores: array[50_000_000, int8]  # Arbitrary large preallocation
    size = 2
    elf1 = 0
    elf2 = 1
    part2 = -1

scores[0] = 3
scores[1] = 7

while size < inputInt + 10 or part2 == -1:
    var score = scores[elf1] + scores[elf2]
    
    if score >= 10:
        scores[size] = 1
        size.inc

        if 1 == lastDigit and size > input.len and scores[size-input.len..size-2] == inputHead:
            part2 = size - input.len

    let newScore = cast[int8](score mod 10)
    scores[size] = newScore
    size.inc

    if newScore == lastDigit and size > input.len and scores[size-input.len..size-2] == inputHead:
        part2 = size - input.len

    elf1 = (elf1 + scores[elf1] + 1) mod size
    elf2 = (elf2 + scores[elf2] + 1) mod size

echo scores[inputInt..inputInt+9].join
echo part2