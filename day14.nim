import sequtils, strutils

let
    input = readFile("data/14.txt").strip
    inputSeq = input.map do (c: char) -> int: cast[int](c) - 48
    lastDigit = inputSeq[inputSeq.len - 1]
    inputInt = input.parseInt

var
    scores = newSeq[int](100_000_000)  # Arbitrary large preallocation
    size = 2
    elf1 = 0
    elf2 = 1
    part2 = -1

scores[0] = 3
scores[1] = 7

while size < inputInt + 10 or part2 == -1:
    var score = scores[elf1] + scores[elf2]
    
    if score >= 10:
        let newScore = score div 10
        scores[size] = newScore
        size.inc

        if newScore == lastDigit and size > input.len and scores[size-input.len..size-1] == inputSeq:
            part2 = size - input.len

    let newScore = score mod 10
    scores[size] = newScore
    size.inc

    if newScore == lastDigit and size > input.len and scores[size-input.len..size-1] == inputSeq:
        part2 = size - input.len

    elf1 = (elf1 + scores[elf1] + 1) mod size
    elf2 = (elf2 + scores[elf2] + 1) mod size

echo scores[inputInt..inputInt+9].join
echo part2