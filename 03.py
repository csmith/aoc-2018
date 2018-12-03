import re
from collections import defaultdict

with open('data/03.txt', 'r') as file:
    cells = defaultdict(lambda: 0)
    claims = map(lambda l: map(int, re.findall(r'\d+', l)), file.readlines())
    ids = set()
    overlaps = 0

    for (cid, x, y, width, height) in claims:
        collision = False
        for i in range(width):
            for j in range(height):
                previous = cells[(x + i, y + j)]
                if previous == 0:
                    cells[(x + i, y + j)] = cid
                elif previous == -1:
                    collision = True
                else:
                    collision = True
                    overlaps += 1
                    if previous in ids:
                        ids.remove(previous)
                    cells[(x + i, y + j)] = -1

        if not collision:
            ids.add(cid)

    print(overlaps)
    print(list(ids)[0])
