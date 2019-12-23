#!/usr/bin/env julia

include("intcode/intcode.jl")

function run(program)
    computer = Intcode.Computer()
    sqsize = 100
    (xmax, ymax) = (1100,1400)
    (ax, ay) = (0,0)
    (bx, by) = (0,0)
    (ansx, ansy) = (0,0)
    aslope = 0
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
            elseif output == 0 && lastout == 1
	    	(ax, ay) = (x-1, y)
	    end
            if output == 1
                width += 1
            end
            lastout = output
  #          print(output == 0 ? '.' : '#')
        end
	aslope = ay/ax
        bslope = by/bx
	y = (sqsize/bslope + sqsize) / (1/aslope - 1/bslope)
	x = (y + sqsize) / bslope
	if bslope > 0 && aslope > 0 && x != Inf && y != Inf
	   x = ceil(Int, x)
	   y = ceil(Int, y)
	end
	(ansx,ansy) = (x,y)
        println(" bs: $bslope, as: $aslope, (x, y) = ($x, $y)")
 #       println()
    end
    (ansx, ansy)
end

program = readchomp(ARGS[1])
(x,y) = run(program)
println("$x, $y")
println(x * 10000 + y)