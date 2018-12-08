import sequtils, strutils

var
    dependencies: array[26, array[27, bool]]

for line in readFile("data/07.txt").strip.splitlines:
    dependencies[ord(line[36]) - 65][ord(line[5]) - 64] = true

func next_task(status: array[26, array[27, bool]]): int =
    var falses: array[27, bool]
    status.find(falses)

func execute(status: var array[26, array[27, bool]], action: int) =
    status[action][0] = true
    for i in 0..25:
        status[i][action + 1] = false

func part1(dependencies: array[26, array[27, bool]]): string =
    var status: array[26, array[27, bool]]
    status.deepCopy(dependencies)
    for i in 0..25:
        var task = status.next_task
        status.execute(task)
        result &= chr(task + 65)

func part2(dependencies: array[26, array[27, bool]]): int =
    var
        status: array[26, array[27, bool]]
        worker_times: array[5, int]
        task_times: array[26, int]
        completed = ""
        time = 0
        step = 0

    status.deepCopy(dependencies)

    while len(completed) < 26:
        time += step
        step = int.high

        for i in 0..25:
            if task_times[i] > 0: 
                if task_times[i] <= time:
                    task_times[i] = 0
                    completed &= chr(i + 65)
                    status.execute(i)
                else:
                    step = min(step, task_times[i] - time)

        for i in 0..4:
            if worker_times[i] <= time:
                var task = status.next_task
                if task > -1:
                    worker_times[i] = time + 61 + task
                    task_times[task] = time + 61 + task
                    status[task][0] = true
                    step = min(step, 61 + task)

    time

echo dependencies.part1
echo dependencies.part2