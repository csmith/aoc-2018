import math, sequtils, strscans, strutils

var
    serial = readFile("data/11.txt").strip.parseInt
    prefixSum: array[301, array[301, int]]

for x in 1..300:
    let serialByRack = (x + 10) * serial
    let rackSquared = (x + 10) * (x + 10)
    var tally = serialByRack
    for y in 1..300:
        tally.inc(rackSquared)
        let power = tally div 100 mod 10 - 5
        # Construct a prefix sum of the grid: prefixSum[x][y] holds the sum of
        # all cells in the rectangle from (0,0) to (x,y). We calculate this
        # by adding the current cell to the rectangle above and the rectangle
        # to the left. This results in double-counting the rect between (0,0)
        # and (x-1,y-1), so we subtract that from the result.
        prefixSum[x][y] = power + prefixSum[x][y-1] +
                            prefixSum[x-1][y] - prefixSum[x-1][y-1]

var
    best = int.low
    bestPos = ""
    bestThree = int.low
    bestThreePos = ""

for size in 1..300:
    let s1 = size - 1
    for x in 1..300 - size:
        for y in 1..300 - size:
            # To use the prefix sum to find the value of a rect, we take the
            # value for the lower right corner and subtract the rects to the
            # left and the top. Like when constructing the prefix sum this
            # double-counts the rectangle diagonally to the top left, so we
            # re-add that.
            var sum = prefixSum[x+s1][y+s1] - prefixSum[x-1][y+s1] -
                        prefixSum[x+s1][y-1] + prefixSum[x-1][y-1]
            if sum > best:
                best = sum
                bestPos = $x & "," & $y & "," & $size
            if size == 3 and sum > bestThree:
                bestThree = sum
                bestThreePos = $x & "," & $y

echo bestThreePos
echo bestPos