import sequtils, strutils

let ops = [
    proc(regs: seq[int], a,b: int): int = regs[a] + b,
    proc(regs: seq[int], a,b: int): int = regs[a] + regs[b],

    proc(regs: seq[int], a,b: int): int = regs[a] * b,
    proc(regs: seq[int], a,b: int): int = regs[a] * regs[b],

    proc(regs: seq[int], a,b: int): int = regs[a] and b,
    proc(regs: seq[int], a,b: int): int = regs[a] and regs[b],

    proc(regs: seq[int], a,b: int): int = regs[a] or b,
    proc(regs: seq[int], a,b: int): int = regs[a] or regs[b],

    proc(regs: seq[int], a,b: int): int = a,
    proc(regs: seq[int], a,b: int): int = regs[a],

    proc(regs: seq[int], a,b: int): int = cast[int](a > regs[b]),
    proc(regs: seq[int], a,b: int): int = cast[int](regs[a] > b),
    proc(regs: seq[int], a,b: int): int = cast[int](regs[a] > regs[b]),

    proc(regs: seq[int], a,b: int): int = cast[int](a == regs[b]),
    proc(regs: seq[int], a,b: int): int = cast[int](regs[a] == b),
    proc(regs: seq[int], a,b: int): int = cast[int](regs[a] == regs[b]),
]

func toInstr(line: string): seq[int] = line.strip.split(" ").map(parseInt)
func toRegisterSample(line: string): seq[int] = line.substr(9, line.len - 2).split(", ").map(parseInt)

proc execute(regs: var seq[int], instr: seq[int], opcodes: array[16, proc(regs: seq[int], a,b: int): int]) =
    regs[instr[3]] = opcodes[instr[0]](regs, instr[1], instr[2])

var
    before, instr, after: seq[int]
    opPossibilities: array[16, array[16, bool]]
    opMappings: array[16, proc(regs: seq[int], a,b: int): int]
    threeOrMore = 0
    step = 0
    registers = @[0, 0, 0, 0]

for line in readFile("data/16.txt").splitlines:
    if step == 0 and line.len > 6 and line[0..5] == "Before":
        before = line.toRegisterSample
        step.inc
    elif step == 1:
        instr = line.toInstr
        step.inc
    elif step == 2:
        after = line.toRegisterSample
        var count = 0
        for i, op in ops:
            var actual: seq[int]
            actual.shallowCopy(before)
            actual[instr[3]] = op(before, instr[1], instr[2])
            if actual == after:
                count.inc
            else:
                opPossibilities[instr[0]][i] = true
        if count >= 3:
            threeOrMore.inc
        step = 0
    
    if step == 0 and line.len > 5 and line[0].isdigit:
        # First instruction found after the samples -- figure out which
        # opcode belongs to which...
        var found: array[16, bool]
        while not found.all(proc(v: bool): bool = v):
            for opcode, possibilities in opPossibilities:
                let matrix = zip(possibilities, found)
                if matrix.count((false, false)) == 1:
                    let index = matrix.find((false, false))
                    found[index] = true
                    opMappings[opcode] = ops[index]
        step = -1
    
    if step == -1:
        registers.execute(line.toInstr, opMappings)

echo threeOrMore
echo registers[0]