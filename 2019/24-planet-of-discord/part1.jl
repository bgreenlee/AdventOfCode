#!/usr/bin/env julia

function cycle(bugs)
    function countneighbors(loc)
        (x,y) = loc
        neighbors = Set([(x, y-1), (x+1, y), (x, y+1), (x-1, y)])
        length(intersect(neighbors, bugs))
    end

    newbugs = Set{Tuple{Int,Int}}()
    for row in 1:5
        for col in 1:5
            numneighbors = countneighbors((col, row))
            if (col, row) in bugs
                # a bug dies unless there is exactly one bug adjacent to it
                if numneighbors == 1
                    push!(newbugs, (col, row))
                end
            else
                # An empty space becomes infested with a bug if exactly one or two bugs are adjacent to it.
                if numneighbors == 1 || numneighbors == 2
                    push!(newbugs, (col, row))
                end
            end
        end
    end
    newbugs
end

function parsemap(map)
    bugs = Set{Tuple{Int,Int}}()
    for row in eachindex(map)
        for col in eachindex(map[row])
            if map[row][col] == '#'
                push!(bugs, (col, row))
            end
        end
    end
    bugs
end

function display(bugs)
    for row in 1:5
        for col in 1:5
            print((col, row) in bugs ? '#' : '.')
        end
        println()
    end
end

function calculaterating(bugs)
    rating = 0
    for (col, row) in bugs
        rating += 2^((row - 1) * 5 + col - 1)
    end
    rating
end

function findcycle(bugs)
    ratings = Set()
    while true
        display(bugs)
        r = calculaterating(bugs)
        println("rating: $r\n")
        if r in ratings
            return r
        end
        push!(ratings, r)
        bugs = cycle(bugs)
    end
end

map = readlines(ARGS[1])
bugs = parsemap(map)
rating = findcycle(bugs)
println(rating)
