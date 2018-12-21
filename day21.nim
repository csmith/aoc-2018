import elfcode, math, sequtils, strutils, sets

var
    instructionSet = readInstructions(readFile("data/21.txt").strip.splitlines)
    seen = initSet[int](15000.nextPowerOfTwo)
    last = 0

iterator emulate(): int =
    var r1, r4 = 0
    
    while true:
        r4 = r1 or 65536
        r1 = instructionSet.instructions[7].a
        
        while r4 > 0:
            r1 = (((r1 + (r4 and 255)) and instructionSet.instructions[10].b) *
                    instructionSet.instructions[11].b) and instructionSet.instructions[12].b
            r4 = r4 div 256
        yield r1

for i in emulate():
    if seen.len == 0:
        echo i
    if seen.containsOrIncl(i):
        echo last
        break
    last = i
