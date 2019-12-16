#!/usr/bin/env julia

include("intcode/intcode.jl")

mutable struct Arcade
    computer::Intcode.Computer
    screen::Dict
    joystick::Int
    score::Int

    function Arcade(program::String)
        computer = Intcode.Computer()
        Intcode.load(computer, program)
        computer.memory.data[1] = 2 # set free play
        screen = Dict()
        new(computer, screen, 0, 0)
    end
end

function display(arcade::Arcade)
    println("Score: $(arcade.score)")
    (minx, maxx) = extrema(x -> x[1], keys(arcade.screen))
    (miny, maxy) = extrema(x -> x[2], keys(arcade.screen))
    
    tiles = [' ', '█', '⛄', '✊', '⚽'  ]
    for y in miny:maxy
        for x in minx:maxx
            tile = get(arcade.screen, (x,y), 0)
            print(tiles[tile+1])
        end
        println()
    end
end

function timeout(f, n)
    sleep(n)
    f()
end

function play!(arcade::Arcade)
    @async Intcode.runprogram!(arcade.computer)
    # timeout the computer after a bit because it seems to run forever
    # @async timeout(() -> close(arcade.computer.output), 2)
    ballx = 0
    paddlex = 0
    while true
        try
            # read output
            x = take!(arcade.computer.output)
            y = take!(arcade.computer.output)
            tile = take!(arcade.computer.output)
            # keep track of the ball & paddle
            if tile == 3
                paddlex = x
            elseif tile == 4
                ballx = x
                # move joystick
                arcade.joystick = cmp(ballx, paddlex)
                # send joystick position
                put!(arcade.computer.input, arcade.joystick)
                # println("ballx: $ballx")
            end

            if x == -1 && y == 0
                arcade.score = tile
                run(`clear`)
                display(arcade)
            else
                arcade.screen[(x,y)] = tile
            end
        catch # channel closed
            break
        end
    end
end

program = ARGS[1]
if isfile(program)
    program = read(program, String)
end

arcade = Arcade(program)
play!(arcade)
display(arcade)