#!/usr/bin/env julia

s = 307237
e = 769058

function isvalid(n::Int64)::Bool
    has_double = false

    nstr = string(n)
    last_digit = nstr[1]
    for i in 2:length(nstr)
        if nstr[i] < last_digit
            return false
        elseif nstr[i] == last_digit
            has_double = true
        end
        last_digit = nstr[i]
    end

    return has_double
end
  
valid = filter(isvalid, s:e)
println("Num valid: $(length(valid))")
