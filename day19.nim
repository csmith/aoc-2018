import math, sequtils, strutils, tables

type instr = tuple[op: string, a,b,c: int]

let ops = {
    "addi": proc(regs: seq[int], a,b: int): int = regs[a] + b,
    "addr": proc(regs: seq[int], a,b: int): int = regs[a] + regs[b],

    "muli": proc(regs: seq[int], a,b: int): int = regs[a] * b,
    "mulr": proc(regs: seq[int], a,b: int): int = regs[a] * regs[b],

    "bani": proc(regs: seq[int], a,b: int): int = regs[a] and b,
    "banr": proc(regs: seq[int], a,b: int): int = regs[a] and regs[b],

    "bori": proc(regs: seq[int], a,b: int): int = regs[a] or b,
    "borr": proc(regs: seq[int], a,b: int): int = regs[a] or regs[b],

    "seti": proc(regs: seq[int], a,b: int): int = a,
    "setr": proc(regs: seq[int], a,b: int): int = regs[a],

    "gtir": proc(regs: seq[int], a,b: int): int = cast[int](a > regs[b]),
    "gtri": proc(regs: seq[int], a,b: int): int = cast[int](regs[a] > b),
    "gtrr": proc(regs: seq[int], a,b: int): int = cast[int](regs[a] > regs[b]),

    "eqir": proc(regs: seq[int], a,b: int): int = cast[int](a == regs[b]),
    "eqri": proc(regs: seq[int], a,b: int): int = cast[int](regs[a] == b),
    "eqrr": proc(regs: seq[int], a,b: int): int = cast[int](regs[a] == regs[b]),
}.toTable

var
    instructions: seq[instr]
    ip: int

for line in readFile("data/19.txt").strip.splitlines:
    var parts = line.split(' ')
    if parts[0] == "#ip":
        ip = parts[1].parseInt
    else:
        instructions.add((parts[0], parts[1].parseInt, parts[2].parseInt, parts[3].parseInt))

proc findTarget(part2: bool): int =
    # The instructions calculate the sum of all factors of a target number. The
    # target is initialised first, and then execution jumps back to near the
    # start of the program to perform the calculation. To find the target
    # number, we evaluate until a backwards jump and then just take the largest
    # register. (Yuck.)
    var registers = @[if part2: 1 else: 0, 0, 0, 0, 0, 0]
    while true:
        let
            i = registers[ip]
            instr = instructions[i]
        registers[instr.c] = ops[instr.op](registers, instr.a, instr.b)
        registers[ip].inc
        if registers[ip] < i:
            return registers.max

proc factors(n: int): seq[int] =
    for x in 1 .. int(sqrt(float(n))):
        if n mod x == 0:
            result.add(x)
            result.add(n div x)
   
echo findTarget(false).factors.sum
echo findTarget(true).factors.sum