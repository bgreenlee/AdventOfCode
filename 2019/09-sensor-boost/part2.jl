#!/usr/bin/env julia

using Combinatorics

# read the Intcode program from stdin and return an array of Ints
function read_program(program_str)
    opcodes = split(program_str, ",")
    opcodes = map(n -> tryparse(Int, n), opcodes)
    filter(n -> n != nothing, opcodes) # remove any bad input
end

# split the opcode into (opcode, param_modes)
function split_opcode(opcode)
    max_params = 3
    opcode_str = string(opcode, pad=max_params+2)
    base_opcode = parse(Int, opcode_str[end-1:end])
    param_modes = reverse(map(c -> parse(Int, c), collect(opcode_str[1:3])))
    base_opcode, param_modes
end

function run_program!(mem, input_channel, output_channel)
    ptr = 1
    relative_base = 0
    while ptr <= length(mem)
        opcode, pm = split_opcode(mem[ptr])
        
        if opcode == 1 # add
            p1 = pm[1] == 0 ? mem[mem[ptr+1]+1] : pm[1] == 1 ?  mem[ptr+1] : mem[mem[ptr+1]+1+relative_base]
            p2 = pm[2] == 0 ? mem[mem[ptr+2]+1] : pm[2] == 1 ?  mem[ptr+2] : mem[mem[ptr+2]+1+relative_base]
            if pm[3] == 2
                mem[mem[ptr+3]+1+relative_base] = p1 + p2
            else
                mem[mem[ptr+3]+1] = p1 + p2
            end
            ptr += 4
        elseif opcode == 2 # multiply
            p1 = pm[1] == 0 ? mem[mem[ptr+1]+1] : pm[1] == 1 ?  mem[ptr+1] : mem[mem[ptr+1]+1+relative_base]
            p2 = pm[2] == 0 ? mem[mem[ptr+2]+1] : pm[2] == 1 ?  mem[ptr+2] : mem[mem[ptr+2]+1+relative_base]
            if pm[3] == 2
                mem[mem[ptr+3]+1+relative_base] = p1 * p2
            else
                mem[mem[ptr+3]+1] = p1 * p2
            end
            ptr += 4
        elseif opcode == 3 # input
            if pm[1] == 2
                mem[mem[ptr+1]+1+relative_base] = take!(input_channel)
            else
                mem[mem[ptr+1]+1] = take!(input_channel)
            end
            ptr += 2
        elseif opcode == 4 # output
            p1 = pm[1] == 0 ? mem[mem[ptr+1]+1] : pm[1] == 1 ?  mem[ptr+1] : mem[mem[ptr+1]+1+relative_base]
            put!(output_channel, p1)
            ptr += 2
        elseif opcode == 5 # jump-if-true
            p1 = pm[1] == 0 ? mem[mem[ptr+1]+1] : pm[1] == 1 ?  mem[ptr+1] : mem[mem[ptr+1]+1+relative_base]
            p2 = pm[2] == 0 ? mem[mem[ptr+2]+1] : pm[2] == 1 ?  mem[ptr+2] : mem[mem[ptr+2]+1+relative_base]
            if p1 != 0
                ptr = p2+1
            else
                ptr += 3
            end
        elseif opcode == 6 # jump-if-false
            p1 = pm[1] == 0 ? mem[mem[ptr+1]+1] : pm[1] == 1 ?  mem[ptr+1] : mem[mem[ptr+1]+1+relative_base]
            p2 = pm[2] == 0 ? mem[mem[ptr+2]+1] : pm[2] == 1 ?  mem[ptr+2] : mem[mem[ptr+2]+1+relative_base]
            if p1 == 0
                ptr = p2+1
            else
                ptr += 3
            end
        elseif opcode == 7 # less than
            p1 = pm[1] == 0 ? mem[mem[ptr+1]+1] : pm[1] == 1 ?  mem[ptr+1] : mem[mem[ptr+1]+1+relative_base]
            p2 = pm[2] == 0 ? mem[mem[ptr+2]+1] : pm[2] == 1 ?  mem[ptr+2] : mem[mem[ptr+2]+1+relative_base]
            if pm[3] == 2
                mem[mem[ptr+3]+1+relative_base] = p1 < p2 ? 1 : 0
            else
                mem[mem[ptr+3]+1] = p1 < p2 ? 1 : 0
            end
            ptr += 4
        elseif opcode == 8 # equals
            p1 = pm[1] == 0 ? mem[mem[ptr+1]+1] : pm[1] == 1 ?  mem[ptr+1] : mem[mem[ptr+1]+1+relative_base]
            p2 = pm[2] == 0 ? mem[mem[ptr+2]+1] : pm[2] == 1 ?  mem[ptr+2] : mem[mem[ptr+2]+1+relative_base]
            if pm[3] == 2
                mem[mem[ptr+3]+1+relative_base] = p1 == p2 ? 1 : 0
            else
                mem[mem[ptr+3]+1] = p1 == p2 ? 1 : 0
            end
            ptr += 4
        elseif opcode == 9 # adjust relative base
            p1 = pm[1] == 0 ? mem[mem[ptr+1]+1] : pm[1] == 1 ?  mem[ptr+1] : mem[mem[ptr+1]+1+relative_base]
            relative_base += p1
            ptr += 2
        elseif mem[ptr] == 99
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
mem = zeros(Int, 1024*1024) # 1M should be enough for anyone
mem[1:length(program)] = program

input = Channel(1)
output = Channel(1024)
put!(input, 2)
run_program!(mem, input, output)
for o in output
    println(o)
end
