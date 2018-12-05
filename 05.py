from functools import partial, reduce

with open('data/05.txt', 'r') as file:
    polymer = map(ord, file.readline().strip())


def react(ignored, head, n):
    if n == ignored or n ^ ignored == 32:
        return head
    elif not head:
        return [n]
    elif head[-1] ^ n == 32:
        return head[0:-1]
    else:
        return head + [n]


reacted = reduce(partial(react, 0), polymer, [])
print(len(reacted))
print(min(len(reduce(partial(react, i), reacted, [])) for i in range(ord('A'), ord('Z'))))
