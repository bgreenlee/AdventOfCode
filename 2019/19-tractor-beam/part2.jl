#!/usr/bin/env julia

include("intcode/intcode.jl")

function run(program)
    computer = Intcode.Computer()

    function check(x, y)
        Intcode.load!(computer, program) # if we don't reload each time we get an error
	put!(computer.input, x)
	put!(computer.input, y)
        Intcode.runprogram!(computer)
        take!(computer.output)
    end

    size = 100
    (x, y) = (0,4)
    while true
	output = check(x, y)
	if output == 0
	   x += 1
	   continue
	end

	output = check(x + size - 1, y)
	if output == 0
	   y += 1
	   continue
	end

	output = check(x, y + size - 1)
	if output == 0
	   x += 1
	   continue
	end
	break
    end
    (x, y)
end

program = readchomp(ARGS[1])
(x,y) = run(program)
println("$x, $y")
println(x * 10000 + y)
