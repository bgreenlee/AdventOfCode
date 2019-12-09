#!/usr/bin/env julia

include("intcode.jl")

input = ARGS[1]
if isfile(input)
    input = read(input, String)
end

computer = Intcode.Computer()
Intcode.load(computer, input)

put!(computer.input, 2)
Intcode.run_program!(computer)
for o in computer.output
    println(o)
end
