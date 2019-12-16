#!/usr/bin/env julia

include("intcode/intcode.jl")

function play!(screen, computer)
    task = @async Intcode.runprogram!(computer)
    while !istaskdone(task)
        x = take!(computer.output)
        y = take!(computer.output)
        tile = take!(computer.output)
        screen[(x,y)] = tile
    end
    screen
end

input = read(ARGS[1], String)

computer = Intcode.Computer()
Intcode.load(computer, input)
screen = Dict()
play!(screen, computer)

num_block = count(t -> t == 2, values(screen))
println(num_block)