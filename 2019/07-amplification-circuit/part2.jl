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
    param_modes = zeros(Int, max_params)
    for i in max_params:-1:1
        if opcode - 10^(i+1) > 0
            param_modes[i] = 1
            opcode -= 10^(i+1)
        end
    end
    opcode, param_modes
end

function run_program!(mem, input_channel, output_channel)
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
            mem[mem[ptr+1]+1] = take!(input_channel)
            ptr += 2
        elseif opcode == 4 # output
            p1 = param_modes[1] == 0 ? mem[mem[ptr+1]+1] : mem[ptr+1]
            put!(output_channel, p1)
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
end

mutable struct Amp
    program::Array{Int}
    input::Channel{Int}
    output::Channel{Int}
    Amp(program) = new(program, Channel{Int}(2), Channel{Int}(2))
end

function run(amp::Amp)
    run_program!(copy(amp.program), amp.input, amp.output)
end

# return an array of connected amps with the given phase_setting
function init_amps(program, phase_setting)::Array{Amp}
    amps = map(_ -> Amp(program), phase_setting) # generate amps
    # hook up the amps to each other
    for i in 1:length(amps)
        amps[i].input = i == 1 ? amps[end].output : amps[i-1].output
        put!(amps[i].input, phase_setting[i]) # put the phase setting on the input channel
    end
    amps
end

function find_max_output(program)
    max_output = 0
    max_phase_setting = []
    for phase_setting in permutations(5:9)
        amps = init_amps(program, phase_setting)

        # The main run loop. We initialize the first amp with zero,
        # then kick off each amp async and wait for them to finish
        put!(amps[1].input, 0)
        @sync for amp in amps
            @async run(amp)
        end

        # final output is on the last amp's output channel
        output = take!(amps[end].output)
        if output > max_output
            max_output = output
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
