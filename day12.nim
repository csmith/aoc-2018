import math, sequtils, strscans, strutils, tables

type
    State = tuple[start: int, plants: string]

const
    iterations = 50_000_000_000

func score(state: State): int =
    for i, c in state.plants:
        if c == '#':
            result += i + state.start


func iterate(state: State, rules: ref Table[string, char]): State =
    let
        input = "...." & state.plants & "...."
        start = state.start - 2

    var
        output = ""
        left = -1
        
    for i in 0..input.len - 5:
        let val = rules[input.substr(i, i + 4)]
        output &= val
        if left == -1 and val == '#':
            left = i - 1

    (start + left, output.substr(left).strip(leading=false, chars={'.'}))


proc solve(initialState: State, rules: ref Table[string, char]) =
    var state = initialState

    for i in 1..iterations:
        var nextState = iterate(state, rules)

        if i == 20:
            echo nextState.score

        if state.plants == nextState.plants:
            # Same pattern of plants, they're just wandering off somewhere.
            let
                difference = nextState.score - state.score
                remaining = iterations - i
                score = nextState.score + difference * remaining
            echo score
            return

        state = nextState

    # If we reach here then the pattern didn't repeat, and it's
    # probably taken an *awfully* long time.
    echo state.score


var
    rules = newTable[string, char]()
    lines = readFile("data/12.txt").strip.splitlines
    initialState: State = (0, lines[0].strip.substr(15))

for line in lines[2..lines.len-1]:
    if line.strip.len > 0:
        rules.add(line.substr(0,4), line.substr(9)[0])

solve(initialState, rules)