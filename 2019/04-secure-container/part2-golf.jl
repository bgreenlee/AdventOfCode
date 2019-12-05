#!/usr/bin/env julia

function isvalid(n::Int64)::Bool
    digits = collect(string(n)) # map number to array of chars
    digits == sort(digits) && findfirst(c -> c == 2, [count(a -> a == b, digits) for b in '0':'9']) != nothing
end

start_num = parse(Int, ARGS[1])
end_num = parse(Int, ARGS[2])

valid = filter(isvalid, start_num:end_num)
println("Num valid: $(length(valid))")
