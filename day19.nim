import elfcode, math, sequtils, strutils, tables

var instructionSet = readInstructions(readFile("data/19.txt").strip.splitlines)

proc findTarget(part2: bool = false): int =
    # The instructions calculate the sum of all factors of a target number. The
    # target is initialised first, and then execution jumps back to near the
    # start of the program to perform the calculation. To find the target
    # number, we evaluate until a backwards jump and then just take the largest
    # register. (Yuck.)
    var registers = @[if part2: 1 else: 0, 0, 0, 0, 0, 0]
    while true:
        let i = instructionSet.ip(registers)
        instructionSet.step(registers)
        if instructionSet.ip(registers) < i:
            return registers.max

proc factors(n: int): seq[int] =
    for x in 1 .. int(sqrt(float(n))):
        if n mod x == 0:
            result.add(x)
            result.add(n div x)
   
echo findTarget().factors.sum
echo findTarget(true).factors.sum