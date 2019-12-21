#!/usr/bin/env julia

include("intcode/intcode.jl")

function run(robot, live=false)
    code = "A,A,B,C,B,C,B,C,B,A\n" * # main
           "R,6,L,12,R,6\n" *        # A
           "L,12,R,6,L,8,L,12\n" *   # B
           "R,12,L,10,L,10\n" *      # C
           "$(live ? 'y' : 'n')\n"                     # video feed

    for c in code
        put!(robot.input, Int(c))
    end

    @async Intcode.runprogram!(robot)

    if live
        Intcode.Display.clear()
    end

    lastchar = '\n'
    for out in robot.output
        if out < 256
            c = Char(out)
            if live && c == '\n' && lastchar == '\n'
                Intcode.Display.goto(1,1)
            end
            lastchar = c
            print(c)
        else
            println(out)
        end
    end
end

program = readchomp(ARGS[1])
live = length(ARGS) > 1 && ARGS[2] == "y"
robot = Intcode.Computer()
Intcode.load!(robot, program)
robot.memory.data[1] = 2 # wake up command
run(robot, live)