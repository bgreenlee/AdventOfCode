#!/usr/bin/env julia

using LinearAlgebra

# This solution exploits the fact that the offset is more than halfway into
# the input, which means that the pattern for a given row is all zeros
# followed by all ones, so the number for a given row is just sum(input[row:end]) % 10
function solve(input)
    for phase = 1:100
        for row = length(input)-1:-1:1
            @inbounds input[row] = (input[row] + input[row+1]) % 10
        end
    end
    input
end

function parseinput(input)
    offset = parse(Int64, input[1:7])
    input = [parse(Int8, c) for c in collect(input)]
    input = repeat(input, 10000)
    input[offset+1:end] # we can ignore everything before offset    
end

input = ARGS[1]
if isfile(input)
    input = readchomp(input)
end

input = parseinput(input)
output = @time solve(input)
println(join(output[1:8]))
