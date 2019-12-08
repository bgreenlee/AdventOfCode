#!/usr/bin/env julia

# parse the given input string in to an array of layers
function get_layers(input, width, height)
    layers = []
    layersize = width * height
    for i in 1:layersize:length(input)
        layer = map(c -> parse(Int, c), collect(input[i:i+layersize-1])) # convert to an array of Ints
        layer = reshape(layer, (width, height)) # turn it into a WxH array
        push!(layers, layer)
    end
    layers
end

# render the layer into a single layer
function render(layers)
    rendered = similar(layers[1])
    fill!(rendered, 2) # default to transparent
    for layer in layers
        for i in eachindex(layer)
            if rendered[i] == 2
                rendered[i] = layer[i]
            end
        end
    end
    rendered
end

function display(image)
    width, height = size(image)
    for y in 1:height
        for x in 1:width
            print(image[x,y] == 0 ? :" " : "■")
        end
        println()
    end
end

width = 25
height = 6
input = chomp(read(ARGS[1], String))
layers = get_layers(input, width, height)
image = render(layers)
display(image)
