#!/usr/bin/env julia

s = 307237
e = 769058

function isvalid(n::Int64)::Bool
    has_double = false

    nstr = string(n)
    for i in 2:length(nstr)
        if nstr[i] < nstr[i-1]
            return false
        elseif nstr[i] == nstr[i-1]
            has_double = true
        end
    end

    return has_double
end
  
valid = filter(isvalid, s:e)
println("Num valid: $(length(valid))")
