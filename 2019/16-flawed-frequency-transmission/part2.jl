#!/usr/bin/env julia

using LinearAlgebra

# fftdot(v1::Array{Int8,1}, v2::Array{Int8,1}) = abs(dot(v1,v2)) % 10

# function buildpattern(size, pos)::Array{Int8,1}
#     base::Array{Int8,1} = [0, 1, 0, -1]
#     base = repeat(base, inner=pos) # expand base
#     pattern::Array{Int8,1} = repeat(base, Int64(ceil(size/length(base))+1)) # fill out to size
#     pattern[pos+1:size+1] # drop the first pos elements and any excess
# end

function fft(input::Array{Int8,1}, n)::Array{Int8,1}
    len = length(input)
    #output = zeros(Int8, len)
    # base::Array{Int8,1} = [0, 1, 0, -1]
    pattern = Array{Int8}(undef, len) # preallocate pattern
    for phase in 1:n
        for pos in 1:len
            base::Array{Int8,1} = [0, 1, 0, -1]
            for i in pos+1:len+1
                @inbounds pattern[i-1] = @fastmath base[(floor(Int32, (i-1)/pos)) % 4 + 1]
            end
#            base = repeat(base, inner=pos) # expand base
#            pattern::Array{Int8,1} = repeat(base, Int64(ceil(len/length(base))+1))[2:len+1] # fill out to size
            @inbounds input[pos] = @fastmath abs(dot(input[pos:end], pattern[pos:end])) % 10
        end
#        input = output
        println("phase $phase: $(join(input[1:8]))")
    end
    input
end

function run(input, phases)
    offset = parse(Int64, input[1:7])
    input::Array{Int8,1} = [parse(Int8, c) for c in collect(chomp(input))]
    input = repeat(input, 1000)
    output = @timev fft(input, phases)
    # message = output[offset+1:offset+9]
    # println(message)
end

input = ARGS[1]
phases = parse(Int, ARGS[2])
if isfile(input)
    input = read(input, String)
end

run(input, phases)
