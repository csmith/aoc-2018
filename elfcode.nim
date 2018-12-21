import strutils, tables

type
    instr* = tuple[op: string, a,b,c: int]
    instructionSet* = tuple[ipr: int, instructions: seq[instr]]

let ops* = {
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

proc readInstructions*(input: seq[string]): instructionSet =
    for line in input:
        var parts = line.split(' ')
        if parts[0] == "#ip":
            result.ipr = parts[1].parseInt
        else:
            result.instructions.add((parts[0], parts[1].parseInt, parts[2].parseInt, parts[3].parseInt))

proc ip*(instructionSet: instructionSet, registers: seq[int]): int {.inline.} =
    registers[instructionSet.ipr]

proc currentInstr*(instructionSet: instructionSet, registers: seq[int]): instr {.inline.} =
    instructionSet.instructions[instructionSet.ip(registers)]

proc step*(instructionSet: instructionSet, registers: var seq[int]) {.inline.} =
    let instr = instructionSet.currentInstr(registers)
    registers[instr.c] = ops[instr.op](registers, instr.a, instr.b)
    registers[instructionSet.ipr].inc
