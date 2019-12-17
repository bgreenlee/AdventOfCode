#!/usr/bin/env julia

using PrettyPrinting

function splitchemical(chemstr)
    (quantitystr, name) = split(strip(chemstr), " ")
    (parse(Int, quantitystr), name)
end

function parsereactions(lines)
    reactions = Dict()
    for line in lines
        (inputstr, outputstr) = split(chomp(line), "=>")
        (quantity, name) = splitchemical(outputstr)

        inputchemicals = [splitchemical(input) for input in split(inputstr, ",")]
        reactions[name] = (quantity, inputchemicals)
    end
    reactions
end

function process(processqueue, reactions)
    ore = 0
    excess = Dict{String,Int}()
    while !isempty(processqueue)
        (quantity, name) = popfirst!(processqueue)
        # if it's ORE, count it
        if name == "ORE"
            ore += quantity
            continue
        end

        # see if we have enough excess to cover this
        if haskey(excess, name)
            excessquantity = excess[name]
            if excessquantity >= quantity
                # got enough excess to cover, so we're done here
                excess[name] -= quantity
                continue
            else
                quantity -= excessquantity
                delete!(excess, name)
            end
        end

        # figure out how many blocks of this we need to make
        (outputquantity, inputs) = reactions[name]
        multiplier = ceil(quantity / outputquantity)
        excessquantity = multiplier * outputquantity - quantity
        excess[name] = get(excess, name, 0) + excessquantity # store excess
        # add each input to the process queue, with quantities multiplied accordingly
        append!(processqueue, [(q * multiplier, name) for (q, name) in inputs])
    end
    ore
end

lines = readlines(ARGS[1])
reactions = parsereactions(lines)
processqueue = [(1, "FUEL")]
ore = process(processqueue, reactions)
println(ore)