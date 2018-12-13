import algorithm, math, sequtils, strscans, strutils, tables

type
    Cart = ref object
        x, y, dx, dy, turn: int
        crashed: bool

proc newCart(x, y, dx, dy: int): Cart =
    result = new(Cart)
    result.x = x
    result.y = y
    result.dx = dx
    result.dy = dy

proc cmpCarts(x, y: Cart): int =
    if x.y == y.y:
        x.x - y.x
    else:
        x.y - y.y

proc cartsAt(carts: seq[Cart], x,y: int): seq[Cart] =
    for cart in carts:
        if cart.x == x and cart.y == y and not cart.crashed:
            result.add(cart)

proc move(cart: Cart, grid: seq[string]) =
    cart.x += cart.dx
    cart.y += cart.dy

    var
        dx = cart.dx
        dy = cart.dy

    let cell = grid[cart.y][cart.x]
    if cell == '/':
        cart.dx = -dy
        cart.dy = -dx
    if cell == '\\':
        cart.dx = dy
        cart.dy = dx
    elif cell == '+':
        if cart.turn == 0:
            cart.dx = dy
            cart.dy = -dx
        elif cart.turn == 2:
            cart.dx = -dy
            cart.dy = dx
        cart.turn = (cart.turn + 1) mod 3

var
    lines = readFile("data/13.txt").splitlines
    grid: seq[string]
    carts: seq[Cart]

for i, line in lines:
    var gridLine = ""
    for j, c in line:
        case c:
            of '>':
                carts.add(newCart(j, i, 1, 0))
                gridLine &= '-'
            of '<':
                carts.add(newCart(j, i, -1, 0))
                gridLine &= '-'
            of 'v':
                carts.add(newCart(j, i, 0, 1))
                gridLine &= '|'
            of '^':
                carts.add(newCart(j, i, 0, -1))
                gridLine &= '|'
            else:
                gridLine &= c
    grid.add(gridLine)

var uncrashed = carts.len

while uncrashed > 1:
    carts.sort(cmpCarts)
    for cart in carts:
        if not cart.crashed:
            cart.move(grid)
            var dupes = carts.cartsAt(cart.x, cart.y)
            if dupes.len > 1:
                if uncrashed == carts.len:
                    echo cart.x, ",", cart.y
                for crash in dupes:
                    crash.crashed = true
                    uncrashed.dec

for cart in carts:
    if not cart.crashed:
        echo cart.x, ",", cart.y