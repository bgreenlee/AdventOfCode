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

struct Asteroid
    coord
    slope
end

# distance between two points
function distance((x1, y1),(x2, y2))
    sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

# Return a dict of (x,y) => [asteroid1, asteroid2, ...], with the asteroinds
# containing the slope of the line between (x,y) and the asteroid
function calculate_slopes(asteroids)
    asteroid_slopes = Dict() # (x,y) => [asteroid1, asteroid2, ...]
    for (x,y) in asteroids
        for (ox, oy) in setdiff(asteroids, [(x,y)])
            slope = atan(oy - y, ox - x)
            asteroid_slopes[(x,y)] = get(asteroid_slopes, (x,y), [])
            push!(asteroid_slopes[(x,y)], Asteroid((ox,oy), slope))
        end
        # sort asteroids by distance
        sort!(asteroid_slopes[(x,y)], by=a -> distance((x,y),(a.coord[1], a.coord[2])))
    end
    asteroid_slopes
end

# Generate a map of (x,y) => n, where n is the number of asteroids visible
# Visibility is calculated by the number of unique slopes to the other
# asteroids (since only one asteroid will be visible at a given slope)
function calculate_visibility(asteroid_slopes)
    Dict([
        (coords, length(unique([a.slope for a in asteroids]))) 
        for (coords, asteroids) in asteroid_slopes
        ])
end

# Sorting function to make upper-left quandrant sort last
function rotate_slopes(x)
    x >= -pi && x < -pi/2 ? x + 2*pi : x
end

function zap_asteroids(asteroids, count=200)
    slopes = [a.slope for a in asteroids]
    # We want our laser to start at the top, but if we do a straight sort
    # by slope, it will start on the left. So we sort by a special function
    # that forces the upper-left quadrant to be sorted last
    sort!(slopes, by=rotate_slopes)
    
    num_zapped = 0
    last_slope = +Inf
    while num_zapped < count && length(slopes) > 1
        s = popfirst!(slopes)
        if s == last_slope
            push!(slopes, s)
        else
            idx = findfirst(a -> a.slope == s, asteroids)
            a = asteroids[idx]
            num_zapped += 1
            println("#$num_zapped: $a")
            deleteat!(asteroids, idx)
        end
        last_slope = s
    end
end

input = readlines(ARGS[1])
map = generate_map(input)
asteroid_slopes = calculate_slopes(map)
visibility = calculate_visibility(asteroid_slopes)
(max, coord) = findmax(visibility)
println("Maxvis: $max at $coord")
zap_asteroids(asteroid_slopes[coord])

