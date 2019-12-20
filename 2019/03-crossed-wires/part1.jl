#!/usr/bin/env julia

import Base.+

struct Point
    x::Int64
    y::Int64
end

function +(a::Point, b::Point)
    Point(a.x + b.x, a.y + b.y)
end

function distance_to_origin(a::Point)::Int64
    abs(a.x) + abs(a.y)
end

struct Line
    a::Point
    b::Point
end

# calculate the intersection point of two lines
# if the lines don't intersect, return 'nothing'
function intersection(l1::Line, l2::Line)
    # represent lines as slope functions ax + by = c
    a1 = l1.b.y - l1.a.y
    b1 = l1.a.x - l1.b.x
    c1 = a1 * l1.a.x + b1 * l1.a.y

    a2 = l2.b.y - l2.a.y
    b2 = l2.a.x - l2.b.x
    c2 = a2 * l2.a.x + b2 * l2.a.y

    determinant = a1*b2 - a2*b1

    if determinant == 0
        # lines are parallel
        return nothing
    end

    x = (b2*c1 - b1*c2) / determinant
    y = (a1*c2 - a2*c1) / determinant

    # make sure the point is actually on a line segments
    # there's probably an easier way to check for this
    if x < min(l1.a.x, l1.b.x) || x > max(l1.a.x, l1.b.x) ||
       y < min(l1.a.y, l1.b.y) || y > max(l1.a.y, l1.b.y) ||
       x < min(l2.a.x, l2.b.x) || x > max(l2.a.x, l2.b.x) ||
       y < min(l2.a.y, l2.b.y) || y > max(l2.a.y, l2.b.y)
       return nothing
    end

    Point(x,y)
end

mutable struct Path
    lines::Array{Line,1}
end

function find_intersections(path1::Path, path2::Path)::Array{Point}
    intersections = []
    for line1 in path1.lines
        for line2 in path2.lines
            intersect = intersection(line1, line2)
            if intersect !== nothing
                push!(intersections, intersect)
            end
        end
    end
    intersections
end

function generate_map(wires)::Array{Path}
    paths = Path[]
    for wire in wires
        last_point = Point(0, 0)
        path = Path([])
        steps = split(wire, ",")
        for step in steps
            direction, distance = step[1], parse(Int, step[2:end])
            move = Point(0, distance) # default Up
            if direction == 'R'
                move = Point(distance, 0)
            elseif direction == 'D'
                move = Point(0, -distance)
            elseif direction == 'L'
                move = Point(-distance, 0)
            else
                # ignore
            end
            next_point = last_point + move
            push!(path.lines, Line(last_point, next_point))
            last_point = next_point
        end
        push!(paths, path)
    end
    paths
end

# test cases
# paths = generate_map(["R8,U5,L5,D3", "U7,R6,D4,L4"])
# ans = 6
# paths = generate_map([
#     "R75,D30,R83,U83,L12,D49,R71,U7,L72"
#     "U62,R66,U55,R34,D71,R55,D58,R83"
# ])
# ans = 159

paths = generate_map(readlines())
intersections = find_intersections(paths[1], paths[2])
sort!(intersections, by=distance_to_origin)
filter!(p -> p != Point(0,0), intersections) # remove origin point
closest = intersections[1]
distance = distance_to_origin(closest)

println("Shortest distance is $distance")
