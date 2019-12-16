#!/usr/bin/env julia

include("intcode/intcode.jl")

function timeout(f, n)
    sleep(n)
    f()
end

function play!(screen, computer)
    @async Intcode.runprogram!(computer)
    # timeout the computer after a bit because it seems to run forever
    @async timeout(() -> close(computer.output), 5)
    while true
        try
            x = take!(computer.output)
            y = take!(computer.output)
            tile = take!(computer.output)
#            println("($x,$y) = $tile")
            screen[(x,y)] = tile
        catch # channel closed
            break
        end
    end
    screen
end

input = ARGS[1]
if isfile(input)
    input = read(input, String)
end

computer = Intcode.Computer()
Intcode.load(computer, input)
screen = Dict()
play!(screen, computer)

num_block = count(t -> t == 2, values(screen))
println(num_block)