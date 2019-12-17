#!/usr/bin/env julia

mutable struct Chemical
    name::String
    quantity::Int

    Chemical(name::String, quantity::Int) = new(name, quantity)
    function Chemical(s::AbstractString)
        (quantitystr, name) = split(strip(s), " ")
        new(name, parse(Int, quantitystr))
    end
end
Base.copy(c::Chemical) = Chemical(c.name, c.quantity)

struct Reaction
    inputs::Array{Chemical}
    output::Chemical
end
Base.copy(r::Reaction) = Reaction(r.inputs, r.output)

function parsereactions(lines)
    reactions = []
    for line in lines
        (inputstr, outputstr) = split(chomp(line), "=>")
        inputchemicals = [Chemical(input) for input in split(inputstr, ",")]
        outputchemical = Chemical(outputstr)
        push!(reactions, Reaction(copy(inputchemicals), copy(outputchemical)))
    end
    reactions
end

# base chemicals are those that can be directly produced by ORE
# we take advantage of the fact that ORE is the only input for these
# output a dict of name => (chem quantity, ore quantity)
function getbasechemicals(reactions)
    Dict([(r.output.name, (r.output.quantity, first(r.inputs).quantity)) for r in filter(r -> first(r.inputs).name == "ORE", reactions)])
end

function reduce!(chemical, reactions, basechemicals, reductions, multiplier=1)
    # if this is a base chemical, figure out how much we need and we're done
    if chemical.name in keys(basechemicals)
        (chemblock, orequantity) = basechemicals[chemical.name]
        chemical.quantity *= multiplier # ceil(chemical.quantity / chemblock) *
        push!(reductions, chemical)
        return
    end

    # find the reaction that produces this chemical
    reaction = reactions[findfirst(r -> r.output.name == chemical.name, reactions)]

    # reduce each of the inputs
    for input in reaction.inputs
        # find the output of the reaction that produces this so we can figure out how much we need
        output = reactions[findfirst(r -> r.output.name == input.name, reactions)].output
        println("output: $output")
        multiplier = ceil(input.quantity / output.quantity)
        println("multiplier: $multiplier")
        input.quantity *= multiplier
        reduce!(input, reactions, basechemicals, reductions, multiplier)
    end
end

function compact(reductions)
    sort!(reductions, by=c->c.name)
    compacted = reductions[1:1]
    for i in 2:length(reductions)
        if reductions[i].name == last(compacted).name
            last(compacted).quantity += reductions[i].quantity
        else
            push!(compacted, reductions[i])
        end
    end
    compacted
end

function calculateore(reactions)
    basechemicals = getbasechemicals(reactions)
    println("base chemicals: $(basechemicals)")
    reductions = []
    reduce!(Chemical("FUEL", 1), reactions, basechemicals, reductions)
    println("reduction: $reductions")
    reductions = compact(reductions)
    println("compacted: $reductions")
    ore = 0
    for chemical in reductions
        (baseblock, baseore) = basechemicals[chemical.name]
        ore += ceil(chemical.quantity / baseblock) * baseore
    end
    ore
end

lines = readlines(ARGS[1])
reactions = parsereactions(lines)
println(calculateore(reactions))
