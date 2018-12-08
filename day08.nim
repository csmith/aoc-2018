import math, sequtils, strutils

func readNode(input: seq[string], start: int): tuple[value: int, metasum: int, offset: int] =
    let
        child_count = input[start + 0].parseInt
        meta_count = input[start + 1].parseInt
    var
        value = 0
        metasum = 0
        offset = start + 2
        child_values: seq[int]
    
    for i in 0 .. child_count - 1:
        var res = readNode(input, offset)
        child_values.add(res.value)
        offset = res.offset
        metasum += res.metasum

    for m in input[offset .. offset + meta_count - 1]:
        var v = m.parseInt
        if v > 0 and v - 1 < child_count:
            value += child_values[v - 1]
        metasum += v
    offset += meta_count
    
    if child_count == 0:
        value = metasum
    (value, metasum, offset)

let root = readNode(readFile("data/08.txt").strip.split(" "), 0)
echo root.metasum
echo root.value