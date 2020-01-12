#!/usr/bin/env julia

# return a tuple representing the linear congruential function (𝑓(𝑥)=𝑎𝑥+𝑏 mod 𝑚)
# that corresponds to the command
# "deal into new stack": 𝑓(𝑥)=−𝑥−1 mod 𝑚, so 𝑎=−1,𝑏=−1
# "cut 𝑛": 𝑓(𝑥)=𝑥−𝑛 mod 𝑚, so 𝑎=1,𝑏=−𝑛
# "deal with increment 𝑛": 𝑓(𝑥)=𝑛⋅𝑥 mod 𝑚, so 𝑎=𝑛,𝑏=0
function lcf(command)
	m = match(r"(cut|deal with increment|deal into new stack)\s*(-?\d+)?$", command)
	if m[1] == "deal into new stack"
		return (-1, -1)
    elseif m[1] == "cut"
		value = parse(Int, m[2])
		return (1, -value)
	elseif m[1] == "deal with increment"
		value = parse(Int, m[2])
		return (value, 0)
   end
end

# reduce our program into a single LCF
function reduce(program, m)
	(a, b) = (1, 0) # identity
	for line in program
		(c, d) = lcf(line)
		(a, b) = (mod(a * c, m), mod(b * c + d, m))
	end
	(a, b)
end

# return the position of the target card after the program has finished
# this is only needed for part1
function shuffle(program, m, target)
	(a, b) = reduce(program, m)
	mod(a * target + b, m)
end

# solve the part2 problem, returning the card that is in position pos
# see https://codeforces.com/blog/entry/72593
function solve(program, m, k, pos)
    (a, b) = reduce(program, m)
    A = powermod(a, k, m)
    B = b * (1 - A) * invmod(1 - a, m)
    # A*pos + B will give us where card "pos" ends up, but we want to know what card is in position pos, so we invert
    mod((pos - B) * invmod(A, m), m)
end

program = readlines(ARGS[1])
decksize = BigInt(119315717514047)
k = BigInt(101741582076661)
pos = 2020
result = solve(program, decksize, k, pos)
println(result)

