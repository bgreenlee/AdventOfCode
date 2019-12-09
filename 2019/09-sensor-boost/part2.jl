#!/usr/bin/env julia

import Base.length
using Combinatorics

# read the Intcode program from stdin and return an array of Ints
function read_program(program_str)
    opcodes = split(program_str, ",")
    opcodes = map(n -> tryparse(Int, n), opcodes)
    filter(n -> n != nothing, opcodes) # remove any bad input
end

# split the opcode into (opcode, param_modes)
function split_opcode(opcode::Int)
    max_params = 3
    opcode_str = string(opcode, pad=max_params+2)
    code = parse(Int, opcode_str[end-1:end])
    param_modes = reverse(map(c -> parse(Int, c), collect(opcode_str[1:3])))
    code, param_modes
end

struct Operation
    code::Int
    pmodes::Array{Int}
    Operation(opcode::Int) = new(split_opcode(opcode)...)
end

mutable struct Memory
    data::Array{Int}
    relbase::Int
    Memory(data) = new(data, 0)
end

load(mem::Memory, program) = mem.data[1:length(program)] = program
length(mem::Memory) = length(mem.data)

function readmem(mem::Memory, ptr, mode=1)
    if mode == 0 # position mode
        mem.data[mem.data[ptr]+1]
    elseif mode == 1 # absolute mode
        mem.data[ptr]
    else # relative mode
        mem.data[mem.data[ptr]+1+mem.relbase]
    end
end

function writemem!(mem::Memory, ptr, mode, value)
    relative = mode == 2 ? mem.relbase : 0
    mem.data[mem.data[ptr]+1+relative] = value
end
    
function getparams(mem::Memory, ptr, modes, count)
    [readmem(mem, ptr+i, modes[i]) for i in 1:count]
end

function run_program!(mem::Memory, input_channel, output_channel)
    ptr = 1
    while ptr <= length(mem)
        op = Operation(readmem(mem, ptr))
        params = getparams(mem, ptr, op.pmodes, 2)

        if op.code == 1 # add
            writemem!(mem, ptr+3, op.pmodes[3], params[1] + params[2])
            ptr += 4
        elseif op.code == 2 # multiply
            writemem!(mem, ptr+3, op.pmodes[3], params[1] * params[2])
            ptr += 4
        elseif op.code == 3 # input
            writemem!(mem, ptr+1, op.pmodes[1], take!(input_channel))
            ptr += 2
        elseif op.code == 4 # output
            put!(output_channel, params[1])
            ptr += 2
        elseif op.code == 5 # jump-if-true
            ptr = params[1] == 0 ? ptr + 3 : params[2] + 1
        elseif op.code == 6 # jump-if-false
            ptr = params[1] == 0 ? params[2] + 1 : ptr + 3
        elseif op.code == 7 # less than
            writemem!(mem, ptr+3, op.pmodes[3], params[1] < params[2] ? 1 : 0)
            ptr += 4
        elseif op.code == 8 # equals
            writemem!(mem, ptr+3, op.pmodes[3], params[1] == params[2] ? 1 : 0)
            ptr += 4
        elseif op.code == 9 # adjust relative base
            mem.relbase += params[1]
            ptr += 2
        elseif op.code == 99
            close(output_channel)
            break
        else
            print("unknown opcode: $(mem[ptr]) at #$ptr\n")
        end
    end
end

input = ARGS[1]
if isfile(input)
    input = read(input, String)
end
program = read_program(input)
mem = Memory(zeros(Int, 1024*1024)) # 1M should be enough for anyone
load(mem, program)

input = Channel(1)
output = Channel(1024)
put!(input, 2)
run_program!(mem, input, output)
for o in output
    println(o)
end
