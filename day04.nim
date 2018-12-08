import algorithm, math, sequtils, strutils, tables

var
    guard, sleep: int
    sleeps = initTable[int, array[60, int]](64)

for line in readFile("data/04.txt").strip.splitlines.sorted(system.cmp[string]):
    var action = line[line.len-5..line.len-1]
    case action
        of "shift":
            guard = line[26..line.len-14].parseInt
            if not sleeps.haskey(guard):
                var sleepRecord: array[60, int]
                sleeps[guard] = sleepRecord
        of "sleep":
            sleep = line[15..16].parseInt
        else:
            for m in sleep..line[15..16].parseInt - 1:
                sleeps[guard][m].inc

var
    mostSleepyGuard = -1
    mostSleepyGuardSleepiestMinute = -1
    mostSleepyGuardCount = -1

    mostSleepyMinute = -1
    mostSleepyMinuteCount = -1
    mostSleepyMinuteGuard = -1

for pair in sleeps.pairs:
    var sleepiest = pair[1].max
    if sleepiest > mostSleepyMinuteCount:
        mostSleepyMinuteCount = sleepiest
        mostSleepyMinute = pair[1].find(sleepiest)
        mostSleepyMinuteGuard = pair[0]
    
    var sleepCount = pair[1].sum
    if sleepCount > mostSleepyGuardCount:
        mostSleepyGuardCount = sleepCount
        mostSleepyGuardSleepiestMinute = pair[1].find(sleepiest)
        mostSleepyGuard = pair[0]

echo mostSleepyGuard * mostSleepyGuardSleepiestMinute
echo mostSleepyMinuteGuard * mostSleepyMinute