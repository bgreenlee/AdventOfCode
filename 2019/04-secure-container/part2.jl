#!/usr/bin/env julia

function isvalid(n::Int64)::Bool
    has_double = false

    nstr = string(n)
    for i in 2:length(nstr)
        if nstr[i] < nstr[i-1]
            return false
        elseif nstr[i] == nstr[i-1] && (i < 3 || nstr[i] != nstr[i-2]) && (i == length(nstr) || nstr[i] != nstr[i+1])
            has_double = true
        end
    end

    has_double
end

start_num = parse(Int, ARGS[1])
end_num = parse(Int, ARGS[2])

valid = filter(isvalid, start_num:end_num)
println("Num valid: $(length(valid))")
