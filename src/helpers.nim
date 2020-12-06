proc inc(n: int): int =
    if current == '\n' and direction == East:
        0
    elif xy.y == code_box.natural_space.high():
        0
    else:
        n + 1
        
proc dec(n: int): int =
    if xy.x == 0 and direction == West:
        code_box.natural_space[0].high
    elif xy.y == 0 and direction == North:
        code_box.natural_space.high
    else: n - 1

proc `>=>`(xy: var tuple[x: int, y: int]): void =
    already_moved = true
    case direction
    of East:
        xy.x = inc xy.x
    of North:
        xy.y = dec xy.y
    of South:
        xy.y = inc xy.y
    of West:
        xy.x = dec xy.x

proc jump(n: int) =
    var i = -1
    while i < n:
        >=> xy
        i += 1

proc `|>`(c: tuple[x: int, y: int]) =
    already_moved = true
    xy.x = c[0]
    xy.y = c[1]

proc pop(s: Stack): FishRecord =
    pop(s.stk)

proc push(s: Stack, r: FishRecord) =
    s.stk.add(r)

proc push(s: Stack, r: int) =
    s.stk.add(fishRecord(r))

proc top(s: Stack): FishRecord =
    s.stk[^1]

proc push_char_at(self: var CodeBox, x: int, y: int, c: char) =
    if x >= 0 and y >= 0:
        if x <= self.natural_space[0].high and y <= self.natural_space.high:
            self.natural_space[y][x] = c
    else:
        let negative_indices = collect(newSeq):
            for i in self.negative_space:
                i.coords
        let tup: tuple[x: int, y: int] = (x, y)
        if tup in negative_indices:
            self.negative_space[negative_indices.find tup].value = c.int.fishRecord
        else: self.negative_space.add( (
            coords: (x, y),
            value: fishRecord(c.int)
        ))

proc get_value_at(self: CodeBox, x: int, y: int): FishRecord =
    if x >= 0 and y >= 0:
        if x <= self.natural_space[0].high and y <= self.natural_space.high:
            let preresult = self.natural_space[y][x]
            if preresult == ' ':
                result = 0.fishRecord
            else: result = preresult.int.fishRecord
    else:
        let negative_indices = collect(newSeq):
            for i in self.negative_space:
                i.coords
        let tup: tuple[x: int, y: int] = (x, y)
        if tup in negative_indices:
            return self.negative_space[negative_indices.find tup].value
        else: return 0.fishRecord

proc get_char_at(self: CodeBox, x: int, y: int): char =
    if x >= 0 and y >= 0:
        if x <= self.natural_space[0].high and y <= self.natural_space.high:
            return self.natural_space[y][x]
            
    else:
        let negative_indices = collect(newSeq):
            for i in self.negative_space:
                i.coords
        let tup: tuple[x: int, y: int] = (x, y)
        if tup in negative_indices:
            return char ~(self.negative_space[negative_indices.find tup].value)

proc digits(s: string, x: Natural): string =
    if s.len <= x:
        s
    else:
        s[0..x]
