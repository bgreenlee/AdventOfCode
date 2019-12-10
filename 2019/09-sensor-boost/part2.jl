#!/usr/bin/env julia

include("intcode/intcode.jl")

input = ARGS[1]
if isfile(input)
    input = read(input, String)
end

computer = Intcode.Computer()
Intcode.load(computer, input)

put!(computer.input, 2)
Intcode.runprogram!(computer)
for o in computer.output
    println(o)
end
