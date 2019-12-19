#!/usr/bin/env julia

using LinearAlgebra

fftdot(v1, v2) = abs(dot(v1,v2)) % 10

function buildpattern(size, pos)
    base = [0, 1, 0, -1]
    base = repeat(base, inner=pos) # expand base
    pattern = repeat(base, Int(ceil(size/length(base))+1)) # fill out to size
    pattern[2:size+1] # drop the first element and any excess
end

function runfft(input, n)
    for phase = 1:n
        input = [fftdot(input, buildpattern(length(input), pos)) for pos in 1:length(input)]
        output = join(input)[1:8]
        println("phase $phase: $output")
    end
end

input = ARGS[1]
phases = parse(Int, ARGS[2])
if isfile(input)
    input = read(input, String)
end
input = [parse(Int, c) for c in collect(chomp(input))]
runfft(input, phases)