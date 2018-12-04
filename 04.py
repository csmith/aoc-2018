from collections import defaultdict, Counter

sleeps = defaultdict(Counter)

with open('data/04.txt', 'r') as file:
    guard = sleep = 0

    for log in sorted(line.strip() for line in file):
        action = log[-5:]
        if action == 'shift':
            guard = log[26:-13]
        elif action == 'sleep':
            sleep = int(log[15:17])
        else:
            sleeps[guard].update(range(sleep, int(log[15:17])))

most_sleep = max(sleeps.items(), key=lambda p: sum(p[1].values()))
print(int(most_sleep[0]) * most_sleep[1].most_common(1)[0][0])

sleepiest_minute = max([(guard, times.most_common(1)[0]) for (guard, times) in sleeps.items()], key=lambda p: p[1][1])
print(int(sleepiest_minute[0]) * sleepiest_minute[1][0])
