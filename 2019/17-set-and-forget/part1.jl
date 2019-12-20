#!/usr/bin/env julia

include("intcode/intcode.jl")

mutable struct Robot
    computer::Intcode.Computer

    function Robot(program::String)
        computer = Intcode.Computer()
        Intcode.load!(computer, program)
        new(computer)
    end
end

function generatemap(robot)
    scaffold = Set()
    (x,y) = (0,0)
    Intcode.runprogram!(robot.computer)
    for output in robot.computer.output
        output = Char(output)
        if output == '#'
            push!(scaffold, (x,y))
        elseif output == '\n'
            y += 1
            x = -1
        end
        x += 1
        print(output)
    end
    scaffold
end

function intersections(scaffold)
    [(x,y) for (x,y) in scaffold if (x,y-1) in scaffold && (x+1,y) in scaffold && (x,y+1) in scaffold && (x-1,y) in scaffold]
end

function alignmentparams(scaffold)
    sum([x * y for (x,y) in intersections(scaffold)])
end

program = read(ARGS[1], String)
robot = Robot(program)
scaffold = generatemap(robot)
result = alignmentparams(scaffold)
println(result)

