# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.
import random, options, sugar, os, strutils
from oids import hexbyte
randomize()

from algorithm import reversed

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

func `$*`(r: FishRecord): FishRecord =
    if r.numerator mod r.denominator == 0:
        return fishRecord(r.numerator div r.denominator)
    else:
        var i = 1
        while i <= 5:
            if r.denominator mod i == 0 and r.numerator mod i == 0:
                return FishRecord(
                    numerator: r.numerator div i,
                    denominator: r.denominator div i
                )

func `==`(a: FishRecord, b: FishRecord): bool =
    let a = $*a
    let b = $*b
    if a.numerator == b.numerator and a.denominator == b.denominator:
        return true
    else:
        return ***a == ***b


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
    coords: tuple[x: int, y: int]
    value: FishRecord


type Stack = ref object
    register: Option[FishRecord]
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

var current: char

var direction = East

var code_box: CodeBox

var stack: Stack

var old_stacks: seq[Stack]

var string_mode = false

var done: bool = false

var already_moved = false

var is_cumulative = false

var debug_mode = false

#==============[Helper Procs]

#this is a weird way of implementing this but it keeps things

include helpers

#[
proc get_value_at(x: int, y: int): int =
    if x >= 0 and y >= 0:
        if x <= code_box.natural_space[0].high and y <= code_box.natural_space.high:
            return int code_box.natural_space[y][x]
        elif]#


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
    stack.push y + x

proc divide() =
    let x = pop stack
    let y = pop stack
    stack.push y / x

proc multiply() =
    let x = pop stack
    let y = pop stack
    stack.push y * x

proc subtract() =
    let x = pop stack
    let y = pop stack
    stack.push y - x

proc modulo() =
    let x = ~ pop stack
    let y = ~ pop stack
    stack.push fishRecord y mod x

proc equals() =
    if pop(stack) == pop(stack):
        stack.push 1
    else: stack.push 0
    
proc less() =
    if ~(pop stack) >= ~(pop stack):
        stack.push 1
    else: stack.push 0

proc more() =
    if ~(pop stack) <= ~(pop stack):
        stack.push 1
    else: stack.push 0 

proc quote() =
    string_mode = true

proc dup() =
    stack.push stack.top

proc del() =
    discard pop stack

proc swap() =
    let a = pop stack
    let b = pop stack
    stack.push a
    stack.push b

proc atswap() =
    let a = pop stack
    let b = pop stack
    let c = pop stack
    stack.push a
    stack.push c
    stack.push b
import algorithm
proc reverse() =
    stack.stk.reverse

proc shift_right() =
    let last = pop stack
    stack.stk.insert(last, 0)

proc shift_left() =
    let first = stack.stk[0]
    stack.stk.delete(0)
    stack.push first

proc length() =
    stack.push stack.stk.len

proc new_stack() =
    let n = ~ pop stack
    let to_new_stack = stack.stk[^n..^1]
    old_stacks.add stack
    stack = new Stack
    stack.stk = to_new_stack

proc back_stack() =
    let to_old_stack = stack.stk
    stack = pop old_stacks
    stack.stk.add to_old_stack

var cumulative_o: seq[string] = @[]

proc char_output() =
    if is_cumulative:
        cumulative_o.add $char(~ pop stack)
        echo cumulative_o.join " "
    else:
        stdout.write char(~ pop stack)

proc num_output() =
    if is_cumulative:
        cumulative_o.add $(*** pop stack)
        echo cumulative_o.join " "
    else:
        #echo "wrote"
        stdout.write $(*** pop stack)

proc num_input() =
    try:
        stack.push stdin.readChar.int

    except IOError:
     stack.push -1

proc registerise() =
    if stack.register.isSome:
        stack.push stack.register.get
        stack.register = none(FishRecord)
    else:
        stack.register = some(pop stack)

proc get_extern() =
    let y = ~ stack.pop
    let x = ~ stack.pop
    stack.push code_box.get_value_at(x, y)

proc push_extern() =
    let y = ~ pop stack
    let x = ~ pop stack
    let v = ~ pop stack
    code_box.push_char_at(x, y, v.char)

proc terminate() = done = true




#============[Interpretation]
var sleep_time: int

proc interpret(codelines: seq[string], initial_stack: seq[FishRecord] = @[], output_stack: bool) =
    code_box = CodeBox(
        natural_space: codelines
        )
    stack = new Stack
    stack.stk.add initial_stack
    xy = (0, 0)
    direction = East
    while not done:
        already_moved = false
        sleep(sleep_time)
        if output_stack:
                if stack.register.isSome:
                    echo "Register:", $ *** stack.register.get
                echo     "Stack: ============================="
                for i, r in stack.stk.reversed.pairs:
                    echo "      ", ("|" & ($(*** r))
                                            .digits(7)
                                            .center(7) & "|")
                                        .center(29)
        current = code_box.get_char_at(xy.x, xy.y)
        if debug_mode: 
            echo "currently doing ", current
            echo "currently at ", $xy
            if string_mode: echo "quoting"
        if string_mode:
            if current == '\'' or current == '"':
                string_mode = false
                
            else:
                stack.push current.int
            >=> xy
        else:
            case current
            of '>': go East
            of '<': go West
            of '^': go North
            of 'v': go South
            of '/': up_mirror()
            of '\\': down_mirror()
            of '|': v_mirror()
            of '_': h_mirror()
            of '#': all_mirror()
            of 'x': random_direction()
            of '!': trampoline()
            of '?': conditional_trampoline()
            of '.': jump()
            of '+': add()
            of '-': subtract()
            of '*': multiply()
            of ',': divide()
            of '%': modulo()
            of '=': equals()
            of ')': more()
            of '(': less()
            of '\'', '"': quote()
            of ':': dup()
            of '~': del()
            of '$': swap()
            of '@': atswap()
            of '}': shift_right()
            of '{': shift_left()
            of 'r': reverse()
            of 'l': length()
            of '[': new_stack()
            of ']': back_stack()
            of 'o': char_output()
            of 'n': num_output()
            of 'i': num_input()
            of '&': registerise()
            of 'g': get_extern()
            of 'p': push_extern()
            of ';': terminate()
            of ' ': discard
            else:
                if current in {'a'..'f', '0' .. '9'}:
                    stack.push current.hexbyte.fishRecord
                else: 
                    echo "something smells fishy ..."
                    echo "the character is " & repr(current)

            

            if not already_moved: >=> xy
        


proc display_help() =
    echo """
    Usage: nimfish [args] <file>
        Args:
        | --code="x"    execute the code supplied in "x"
        | -h            display this message
        | -i            initialise the stack with values (integers with comma separators)
        | -s            output the stack each tick
        | -t            time to sleep between ticks in ms
        | -d            prints the current operation every tick
        | --cumulative  the output contains everything the program has output       
    """
   
#====================[Main]
when isMainModule:
    import parseopt
    var code: string
    var received_code = false
    var output_stack = false
    var stack_initialised = false
    var initial_stack: string

    var p = initOptParser(shortNoVal = {'h', 's'}, longNoVal = @["cumulative"])
    while true:
        p.next()

        case p.kind 
        of cmdEnd: break
        of cmdShortOption:
            case p.key 
            of "h": 
                display_help()
                break
            of "s":
            
                output_stack = true
            of "t": 
                sleep_time = 
                    try: parseInt(p.val)
                    except ValueError:
                        echo "That doesn't look like a number"
                        0
            of "i": 
                initial_stack = p.val
                stack_initialised = true
            of "d":
                debug_mode = true 
            else: discard
        of cmdLongOption:
            case p.key
            of "code": 
                code = p.val
                received_code = true
            of "cumulative":
                is_cumulative = true
            else: discard
        of cmdArgument:
            if not received_code:
                received_code = true
                code = readFile p.key
        
    var seqcode: seq[string] = code
                                .splitLines(keepEol = false)
                                .normalise()
        
    if stack_initialised:
        var initial_stack = collect(newSeq):
            for i in initial_stack.split(","):
                i.parseInt.fishRecord

        interpret(seqcode, initial_stack ,output_stack)
    else:
        interpret(seqcode, output_stack=output_stack)        
        

        
    

  




