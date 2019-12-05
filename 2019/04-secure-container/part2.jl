#!/usr/bin/env julia

function isvalid(n::Int64)::Bool
    has_double = false

    s = string(n)
    for i in 2:length(s)
        if s[i] < s[i-1]
            return false
        elseif s[i] == s[i-1] && (i < 3 || s[i] != s[i-2]) && (i == length(s) || s[i] != s[i+1])
            has_double = true
        end
    end

    has_double
end

start_num = parse(Int, ARGS[1])
end_num = parse(Int, ARGS[2])

valid = filter(isvalid, start_num:end_num)
println("Num valid: $(length(valid))")
