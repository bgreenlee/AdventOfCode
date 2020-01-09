function cut(cards, n)
	n >= 0 ? vcat(cards[n + 1:end], cards[1:n]) : 
		     vcat(cards[end + n + 1:end], cards[1:end + n])
end

function dealwithincrement(cards, n)
    newdeck = copy(cards)
    decksize = length(cards)
	for i = 0:n:decksize * n - 1
		newdeck[i % decksize + 1] = cards[Int(i / n) + 1]
	end
	newdeck
end

function position(cards, card)
    idx = findfirst(n->n == card, cards)
    idx - 1
end

function shuffle(program, decksize)
    cards = [n for n = 0:decksize - 1]
    for line in program
       	m = match(r"(cut|deal with increment|deal into new stack)\s*(-?\d+)?$", line)
       	if isnothing(m)
       	    continue
       	end
       	if m[1] == "deal into new stack"
       	    reverse!(cards)
       	elseif m[1] == "cut"
       	    value = parse(Int, m[2])
       	    cards = cut(cards, value)
        elseif m[1] == "deal with increment"
       	    inc = parse(Int, m[2])
       	    cards = dealwithincrement(cards, inc)
       	end
    end
    cards
end
