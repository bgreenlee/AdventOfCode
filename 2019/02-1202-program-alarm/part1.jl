#!/usr/bin/env julia

# read the Intcode program from stdin and return an array of Ints
function readprogram()
    opcodes = split(readline(), ",")
    opcodes = map(n -> tryparse(Int, n), opcodes)
    filter(n -> n != nothing, opcodes) # remove any bad input
end

mem = readprogram()
# patch per instructions
mem[2] = 12
mem[3] = 2
# Julia uses 1-based indexing
ptr = 1

while ptr <= length(mem)
    print("$ptr -> $mem\n")
    global ptr
    if mem[ptr] == 1
        mem[mem[ptr+3]+1] = mem[mem[ptr+1]+1] + mem[mem[ptr+2]+1]
        ptr += 4
    elseif mem[ptr] == 2
        mem[mem[ptr+3]+1] = mem[mem[ptr+1]+1] * mem[mem[ptr+2]+1]
        ptr += 4
    elseif mem[ptr] == 99
        break
    else
        print("unknown opcode: $(mem[ptr]) at #$ptr\n")
    end
end

print("mem[1] = $(mem[1])\n")

