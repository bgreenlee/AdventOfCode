#!/usr/bin/env julia

include("intcode/intcode.jl")

function run(program)
    computer = Intcode.Computer()
    total = 0
    for x = 0:49
        for y = 0:49
            Intcode.load!(computer, program) # if we don't reload each time we get an error
            put!(computer.input, x)
            put!(computer.input, y)
            Intcode.runprogram!(computer)
            output = take!(computer.output)
            total += output
        end
    end
    total
end

program = readchomp(ARGS[1])
result = run(program)
println(result)