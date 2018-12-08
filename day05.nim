import sequtils, strutils

func react(polymer: seq[char], skip: char): seq[char] =
    var count = 0
    for c in polymer:
        if c == skip or (ord(c) xor ord(skip)) == 32:
            continue
        if count > 0:
            if (ord(c) xor ord(result[count - 1])) == 32:
                result.delete(count - 1)
                count -= 1
                continue
        result.add(c)
        count += 1

let polymer = toSeq(readFile("data/05.txt").strip.items).react(' ')

echo polymer.len
echo min(toSeq('A'..'Z').map(proc(c: char): int = len(polymer.react(c))))