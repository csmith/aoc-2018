import itertools


def first_duplicate(values):
    seen = set()
    for item in values:
        if item in seen:
            return item
        seen.add(item)
    return None


with open('data/01.txt', 'r') as file:
    frequencies = list(map(int, file.readlines()))

    print(sum(frequencies))
    print(first_duplicate(itertools.accumulate(itertools.cycle(frequencies))))
