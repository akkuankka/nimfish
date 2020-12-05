# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import nfio
import sequtils
import random
randomize()

#==============[Data Types]================

type FishRecord = object of RootObj
        numerator: int
        denominator: int
    

func fishRecord(n: int): FishRecord =
    FishRecord(numerator: n, denominator: 1)

func `***`(r: FishRecord): float =
    r.numerator / r.denominator

func `~`(r: FishRecord): int =
    r.numerator div r.denominator


func `/`(a: FishRecord, b: FishRecord): FishRecord =
    FishRecord(
        numerator: a.numerator * b.denominator,
        denominator: a.denominator * b.numerator
    )

func `*`(a: FishRecord, b: FishRecord): FishRecord =
    FishRecord(
        numerator: a.numerator * b.numerator,
        denominator: a.numerator * b.numerator
    )
func `+`(a: FishRecord, b: FishRecord): FishRecord =
    if a.denominator == b.denominator:
        FishRecord(
            numerator: a.numerator + b.numerator, 
            denominator: a.denominator
            )
    else:
        FishRecord(
            numerator: a.numerator * b.denominator + b.numerator * a.denominator,
            denominator: a.denominator * b.denominator
        )

func `-`(a: FishRecord, b: FishRecord): FishRecord =
    if a.denominator == b.denominator:
        FishRecord(
            numerator: a.numerator + b.numerator, 
            denominator: a.denominator
            )
    else:
        FishRecord(
            numerator: a.numerator * b.denominator - b.numerator * a.denominator,
            denominator: a.denominator * b.denominator
        )

    

type NSpaceRecord = tuple
    coords: tuple[x: int64, y: int64]
    value: FishRecord

type Stack = ref object
    register: FishRecord
    stk: seq[FishRecord]

type CodeBox = object
    natural_space: seq[string]
    negative_space: seq[NSpaceRecord]

type Directions = enum
    North
    South
    East
    West


#==============[Globals]
var xy:
    tuple[x: int, y: int] = (0, 0)

var current: char = ' '

var direction = East

var code_box: CodeBox

var stack: Stack

var old_stacks: seq[Stack]

#==============[Helper Procs]

#this is a weird way of implementing this but it keeps things

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
    xy.x = c[0]
    xy.y = c[1]

proc pop(s: Stack): FishRecord =
    pop(s.stk)

proc push(s: Stack, r: FishRecord) =
    s.stk.add(r)


#==============[Functionality]

proc go(d: Directions) =
    direction = d

proc up_mirror() =
    case direction
    of North: direction = West
    of West: direction = North
    of South: direction = East
    of East: direction = South

proc down_mirror() = 
    case direction
    of North: direction = East
    of West: direction = South
    of South: direction = West
    of East: direction = North

proc v_mirror() =
    case direction
    of North, South: discard
    of East: direction = West
    of West: direction = East

proc h_mirror() =
    case direction
    of East, West: discard
    of South: direction = North
    of North: direction = South

proc all_mirror() =
    direction = case direction
        of North: South
        of South: North
        of East: West
        of West: East

proc random_direction() =
    case rand(3)
    of 0: direction = North
    of 1: direction = East
    of 2: direction = South
    of 3: direction = West
    else:
        discard

proc trampoline() =
    jump 1

proc conditional_trampoline() =
    jump case *** pop stack
        of 0: 1
        else: 0

proc jump() =
    let y = ~ pop stack
    |>(~ pop stack, y)

proc add() =
    let x = pop stack
    let y = pop stack
    stack.push y / x







#============[Interpretation]
   
#====================[Main]
when isMainModule:
    import os
    

    let code = if paramCount() > 0: readFile paramStr(1)
             else: readAll stdin

  



