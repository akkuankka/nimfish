import os, strutils
proc readInput*(): string =
    stdin.readLine

proc readCharInput*(): char =
    try:
        return stdin.readChar
    except IOError:
        return '-'


