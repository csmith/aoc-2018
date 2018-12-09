import algorithm, math, sequtils, strutils

func readNode(input: var seq[string]): tuple[value: int, metasum: int] =
    let
        child_count = input.pop.parseInt
        meta_count = input.pop.parseInt
    var
        value = 0
        metasum = 0
        child_values: seq[int]
    
    for i in 0 .. child_count - 1:
        var res = readNode(input)
        child_values.add(res.value)
        metasum += res.metasum

    for m in 0 .. meta_count - 1:
        var v = input.pop.parseInt
        if v > 0 and v <= child_count:
            value += child_values[v - 1]
        metasum += v
    
    if child_count == 0:
        value = metasum
    (value, metasum)

var input = readFile("data/08.txt").strip.split(" ").reversed
let root = input.readNode
echo root.metasum
echo root.value