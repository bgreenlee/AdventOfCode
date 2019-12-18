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

function process!(processqueue, reactions, excess)
    ore = 0
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
                excess[name] = 0
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

function calculatefuel!(reactions, ore_reserves=1000000000000)
    excess = Dict{String,Int}()
    fuel = 0
    amtfuel = 1
    while true
        excessbackup = copy(excess)
        # println("processing $amtfuel FUEL")
        processqueue = [(amtfuel, "FUEL")]
        ore = process!(processqueue, reactions, excess)
        ore_reserves -= ore
        # if we've overshot our reserves, back off
        # unless we're at 1 FUEL, in which case we're done
        if ore_reserves < 0
            if amtfuel == 1
                break
            end
            # retry at half the fuel
            ore_reserves += ore
            excess = excessbackup
            amtfuel /= 2
            continue
        end
        fuel += amtfuel
        # println("fuel: $fuel, reserves: $ore_reserves")
        amtfuel *= 2
    end
    fuel
end

lines = readlines(ARGS[1])
reactions = parsereactions(lines)
fuel = calculatefuel!(reactions)
println(convert(BigInt, fuel))