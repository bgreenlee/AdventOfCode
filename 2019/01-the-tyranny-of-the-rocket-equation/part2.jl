#!/usr/bin/env julia

# read in the list of masses from stdin and return an array of Ints
function readmasses()
    masses = map(n -> tryparse(Int, n), readlines())
    filter(n -> n !== nothing, masses) # remove any bad input
end

# calculate the fuel required given the mass
function fuel(m)
    f = floor(Int, m/3) - 2
    f <= 0 ? 0 : f + fuel(f) # recursively include the fuel needed to carry the fuel
end

masses = readmasses()
total = sum(fuel, masses)
print("Total: $total\n")
