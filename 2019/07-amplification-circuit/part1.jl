#!/usr/bin/env julia

using Combinatorics

# read the Intcode program from stdin and return an array of Ints
function read_program(program_str)
    opcodes = split(program_str, ",")
    opcodes = map(n -> tryparse(Int, n), opcodes)
    filter(n -> n !== nothing, opcodes) # remove any bad input
end

# split the opcode into (opcode, param_modes)
function split_opcode(opcode)
    max_params = 3
    param_modes = zeros(Int, max_params)
    for i in max_params:-1:1
        if opcode - 10^(i+1) > 0
            param_modes[i] = 1
            opcode -= 10^(i+1)
        end
    end
    opcode, param_modes
end

function run_program(mem, input...)
    output = 0
    input_ptr = 1
    ptr = 1
    while ptr <= length(mem)
        opcode, param_modes = split_opcode(mem[ptr])
        
        if opcode == 1 # add
            p1 = param_modes[1] == 0 ? mem[mem[ptr+1]+1] : mem[ptr+1]
            p2 = param_modes[2] == 0 ? mem[mem[ptr+2]+1] : mem[ptr+2]
            mem[mem[ptr+3]+1] = p1 + p2
            ptr += 4
        elseif opcode == 2 # multiply
            p1 = param_modes[1] == 0 ? mem[mem[ptr+1]+1] : mem[ptr+1]
            p2 = param_modes[2] == 0 ? mem[mem[ptr+2]+1] : mem[ptr+2]
            mem[mem[ptr+3]+1] = p1 * p2
            ptr += 4
        elseif opcode == 3 # input
            #input = tryparse(Int, readline())
            mem[mem[ptr+1]+1] = input[input_ptr]
            input_ptr += 1
            ptr += 2
        elseif opcode == 4 # output
            p1 = param_modes[1] == 0 ? mem[mem[ptr+1]+1] : mem[ptr+1]
            output = p1
            ptr += 2
        elseif opcode == 5 # jump-if-true
            p1 = param_modes[1] == 0 ? mem[mem[ptr+1]+1] : mem[ptr+1]
            p2 = param_modes[2] == 0 ? mem[mem[ptr+2]+1] : mem[ptr+2]
            if p1 != 0
                ptr = p2+1
            else
                ptr += 3
            end
        elseif opcode == 6 # jump-if-false
            p1 = param_modes[1] == 0 ? mem[mem[ptr+1]+1] : mem[ptr+1]
            p2 = param_modes[2] == 0 ? mem[mem[ptr+2]+1] : mem[ptr+2]
            if p1 == 0
                ptr = p2+1
            else
                ptr += 3
            end
        elseif opcode == 7 # less than
            p1 = param_modes[1] == 0 ? mem[mem[ptr+1]+1] : mem[ptr+1]
            p2 = param_modes[2] == 0 ? mem[mem[ptr+2]+1] : mem[ptr+2]
            mem[mem[ptr+3]+1] = p1 < p2 ? 1 : 0
            ptr += 4
        elseif opcode == 8 # equals
            p1 = param_modes[1] == 0 ? mem[mem[ptr+1]+1] : mem[ptr+1]
            p2 = param_modes[2] == 0 ? mem[mem[ptr+2]+1] : mem[ptr+2]
            mem[mem[ptr+3]+1] = p1 == p2 ? 1 : 0
            ptr += 4
        elseif mem[ptr] == 99
            break
        else
            print("unknown opcode: $(mem[ptr]) at #$ptr\n")
        end
    end

    output
end

function find_max_output(program)
    max_output = 0
    max_phase_setting = []
    for phase_setting in permutations(0:4)
        last_output = 0
        for amp in 1:5
            output = run_program(copy(program), phase_setting[amp], last_output)
            last_output = output
        end
        if last_output > max_output
            max_output = last_output
            max_phase_setting = phase_setting
        end
    end
    return (max_output, max_phase_setting)
end

input = ARGS[1]
if isfile(input)
    input = read(input, String)
end
program = read_program(input)

max_output, max_phase_setting = find_max_output(program)

println("Max output $max_output with phase setting $max_phase_setting")
