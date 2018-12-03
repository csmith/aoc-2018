import re
from collections import defaultdict

with open('data/03.txt', 'r') as file:
    cells = defaultdict(list)
    claims = map(lambda l: map(int, re.findall(r'\d+', l)), file.readlines())
    ids = set()

    for (cid, x, y, width, height) in claims:
        ids.add(cid)
        for i in range(width):
            for j in range(height):
                cells[(x + i, y + j)].append(cid)

    overlaps = [c for c in cells.values() if len(c) > 1]
    print(len(overlaps))

    dupes = set(cid for sublist in overlaps for cid in sublist)
    print(list(ids - dupes)[0])
