#!/usr/bin/env julia

function get_layers(input, width, height)
    layers = []
    layersize = width * height
    for i in 1:layersize:length(input)
        push!(layers, input[i:i+layersize-1])
    end
    layers
end

function find_min_zeros(layers)
    min_zeros = typemax(Int) 
    min_zeros_layer = 0
    for i in eachindex(layers)
        num_zeros = count(c -> c == '0', layers[i])
        if num_zeros < min_zeros
            min_zeros = num_zeros
            min_zeros_layer = i
        end
    end
    min_zeros_layer
end
    
width = 25
height = 6
input = chomp(read(ARGS[1], String))
layers = get_layers(input, width, height)
min_zeros_layer = find_min_zeros(layers)
num_ones = count(c -> c == '1', layers[min_zeros_layer])
num_twos = count(c -> c == '2', layers[min_zeros_layer])
result = num_ones * num_twos
println(result)