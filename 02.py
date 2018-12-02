import itertools
import operator


def count_dupes(box):
    return [any(box.count(x) == i for x in box) for i in (2, 3)]


with open('data/02.txt', 'r') as file:
    boxes = list(map(str.strip, file.readlines()))

    print(operator.mul(*map(sum, zip(*map(count_dupes, boxes)))))

    for box1, box2 in itertools.combinations(boxes, 2):
        common = ''
        missed = 0
        for i, j in zip(box1, box2):
            if i == j:
                common += i
            else:
                missed += 1
                if missed > 1:
                    break

        if missed == 1:
            print(common)
            break
