#!/usr/bin/env julia

global const decksize = 10007

function shuffle(program)
    cut!(n) = cards = n >= 0 ? vcat(cards[n+1:end], cards[1:n]) : vcat(cards[end+n+1:end], cards[1:end+n])

    cards = [n for n=0:decksize-1]
    for line in program
	m = match(r"(cut|deal with increment|deal into new stack)\s*(-?\d+)?$", line)
	if isnothing(m)
	    continue
	end
	if m[1] == "deal into new stack"
	    reverse!(cards)
	elseif m[1] == "cut"
	    value = parse(Int, m[2])
	    cut!(value)
        elseif m[1] == "deal with increment"
	    inc = parse(Int, m[2])
	    newdeck = copy(cards)
	    for n = 0:inc:decksize*inc-1
		newdeck[n % decksize + 1] = cards[Int(n/inc)+1]
	    end
	    cards = newdeck
	end
    end
    cards
end

program = readlines(ARGS[1])
cards = shuffle(program)
idx = findfirst(n -> n == 2019, cards)
println(idx - 1)

