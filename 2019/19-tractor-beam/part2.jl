#!/usr/bin/env julia

include("intcode/intcode.jl")

function run(program)
    computer = Intcode.Computer()
    (xmax, ymax) = (1300,1000)
    (bx, by) = (0,0)
    bslope = 0
    done = false
    for y = 0:ymax
        width = 0
        print(lpad("$y:", 5))
        lastout = 0
        for x = 0:xmax
            Intcode.load!(computer, program) # if we don't reload each time we get an error
            put!(computer.input, x)
            put!(computer.input, y)
            Intcode.runprogram!(computer)
            output = take!(computer.output)
            if x == xmax && output == 1
                done = true
                break
            end
            if output == 1 && lastout == 0
                (bx, by) = (x, y)
            end
            if output == 1
                width += 1
            end
            lastout = output
#            print(output == 0 ? '.' : '#')
        end
        bslope = by/bx
        println(" bs: $bslope, width: $width")
 #       println()
        if width >= 100/bslope + 100
            break
        end
    end
    # do some math
    ansx = bx + 100/(by/bx)
    ansy = by
    (ceil(Int, ansx), ceil(Int, ansy))
end

program = readchomp(ARGS[1])
(x,y) = run(program)
println("$x, $y")
println(x * 10000 + y)