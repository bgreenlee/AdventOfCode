#!/usr/bin/env julia

include("src/shuffle.jl")

program = readlines(ARGS[1])
decksize = 10007
cards = shuffle(program, decksize)
println(position(cards, 2019))

