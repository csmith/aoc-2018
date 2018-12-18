import algorithm, deques, sequtils, strutils

type
    Species = enum
        spElf, spGoblin

    Point = tuple[x,y: int]

    Creep = ref object
        pos: Point
        hp,ap: int
        species: Species

proc cmpCreeps(x, y: Creep): int =
    if x.pos.y == y.pos.y:
        x.pos.x - y.pos.x
    else:
        x.pos.y - y.pos.y

iterator moves(pos: Point): Point =
    yield (pos.x, pos.y-1)
    yield (pos.x-1, pos.y)
    yield (pos.x+1, pos.y)
    yield (pos.x, pos.y+1)

proc highAt(bitmasks: seq[uint64], pos: Point): bool {.inline.} =
    let mask = 1'u64 shl pos.x
    (bitmasks[pos.y] and mask) == mask

func setLowAt(bitmasks: var seq[uint64], pos: Point) {.inline.} =
    bitmasks[pos.y] = bitmasks[pos.y] and not (1'u64 shl pos.x) 

func setHighAt(bitmasks: var seq[uint64], pos: Point) {.inline.} =
    bitmasks[pos.y] = bitmasks[pos.y] or (1'u64 shl pos.x) 

proc inRange(targets: seq[uint64], pos: Point): bool =
    for move in pos.moves:
        if targets.highAt(move):
            return true

proc allDead(targets: seq[uint64]): bool =
    for line in targets:
        if line != 0:
            return false
    return true

proc totalHp(creeps: seq[Creep]): int =
    for creep in creeps:
        if creep.hp > 0:
            result += creep.hp

proc step(targets: seq[uint64], passable: seq[uint64], pos: Point): tuple[valid: bool, step: Point] =
    type Step = tuple[firstStep, pos: Point]
    var
        queue = initDeque[Step]()
        allowed: seq[uint64]
    
    allowed.deepCopy(passable)

    for firstStep in pos.moves:
        if allowed.highAt(firstStep):
            queue.addLast((firstStep, firstStep))
            allowed.setLowAt(firstStep)
    while queue.len > 0:
        let lastStep = queue.popFirst()
        for nextStep in lastStep.pos.moves:
            if targets.highAt(nextStep):
                return (true, lastStep.firstStep)
            if allowed.highAt(nextStep):
                queue.addLast((lastStep.firstStep, nextStep))
                allowed.setLowAt(nextStep)

let
    input = readFile("data/15.txt").strip.splitlines

var
    maxx = int.low
    creeps: seq[Creep]
    passable: seq[uint64]
    goblins: seq[uint64]
    elves: seq[uint64]

proc load(elfAttackPower: int = 3) =
    maxx = int.low
    creeps.setLen(0)
    passable.setLen(0)
    goblins.setLen(0)
    elves.setLen(0)

    for y, line in input:
        var linePassable, lineGoblins, lineElves: uint64
        for x, c in line:
            maxx = max(x, maxx)
            if c == 'E' or c == 'G':
                var creep = new(Creep)
                creep.pos = (x,y)
                creep.hp = 200
                if c == 'E':
                    creep.species = spElf
                    lineElves = lineElves or (1'u64 shl x)
                    creep.ap = elfAttackPower
                else:
                    creep.species = spGoblin
                    lineGoblins = lineGoblins or (1'u64 shl x)
                    creep.ap = 3
                creeps.add(creep)
            elif c == '.':
                linePassable = linePassable or (1'u64 shl x)
        passable.add(linePassable)
        goblins.add(lineGoblins)
        elves.add(lineElves)

proc run(elfAttackPower: int = 3, allowElvesToDie: bool = true): int =
    load(elfAttackPower)
    var runs: int
    while true:
        creeps.sort(cmpCreeps)
        for creep in creeps:
            if creep.hp <= 0:
                continue

            let targets = if creep.species == spGoblin: elves else: goblins
            if targets.allDead:
                return runs * creeps.totalHp
            if not targets.inRange(creep.pos):
                let move = targets.step(passable, creep.pos)
                if move.valid:
                    if creep.species == spGoblin:
                        goblins.setLowAt(creep.pos)
                        goblins.setHighAt(move.step)
                    else:
                        elves.setLowAt(creep.pos)
                        elves.setHighAt(move.step)
                    passable.setHighAt(creep.pos)
                    passable.setLowAt(move.step)
                    creep.pos = move.step
            if targets.inRange(creep.pos):
                let spaces = toSeq(creep.pos.moves)
                var
                    lowestHp = int.high
                    bestCreep: Creep
                for other in creeps:
                    # Find an enemy that's alive
                    if other.species != creep.species and other.hp > 0 and
                        # ... That's in range
                        other.pos in spaces and
                        # ... With lower HP
                        (other.hp < lowestHp or
                        # ... Or the same HP and higher up
                        (other.hp == lowestHp and (other.pos.y < bestCreep.pos.y or
                        # ... Or the same HP and height but further left
                        (other.pos.y == bestCreep.pos.y and other.pos.x < bestCreep.pos.x)))):
                        lowestHp = other.hp
                        bestCreep = other
                bestCreep.hp -= creep.ap
                if bestCreep.hp <= 0:
                    if bestCreep.species == spGoblin:
                        goblins.setLowAt(bestCreep.pos)
                    else:
                        elves.setLowAt(bestCreep.pos)
                        if not allowElvesToDie:
                            return -1
                    passable.setHighAt(bestCreep.pos)
        runs.inc

echo run()

var ap = 4
while true:
    let res = run(ap, false)
    if res > -1:
        echo res
        break
    ap.inc