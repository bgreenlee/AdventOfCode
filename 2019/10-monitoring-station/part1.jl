#!/usr/bin/env julia

function generate_map(rows)
    asteroids = Set{Tuple{Int,Int}}()
    for y in eachindex(rows)
        row = collect(chomp(rows[y]))
        for x in eachindex(row)
            if row[x] == '#'
                push!(asteroids, (x,y))
            end
        end
    end
    asteroids
end

function analyze_map(asteroids)
    visibility = Dict{Tuple{Int,Int}, Int}()
    for (x,y) in asteroids
        slopes = [atan(oy - y, ox - x) for (ox, oy) in setdiff(asteroids, [(x,y)])]
        visibility[(x,y)] = length(unique(slopes))
    end

    visibility
end

input = readlines(ARGS[1])
map = generate_map(input)
visibility = analyze_map(map)
println(findmax(visibility))

