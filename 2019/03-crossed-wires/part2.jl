#!/usr/bin/env julia

import Base.+

struct Point
    x::Int64
    y::Int64
end

function +(a::Point, b::Point)
    Point(a.x + b.x, a.y + b.y)
end

# Manhattan distance between two points
function distance(a::Point, b::Point)::Int64
    abs(a.x - b.x) + abs(a.y - b.y)
end

function distance_to_origin(a::Point)::Int64
    distance(a, Point(0,0))
end

struct Line
    a::Point
    b::Point
end

function length(l::Line)
    distance(l.a, l.b)
end

struct Intersection
    point::Point
    steps::Int64 # sum of paths of the lines that lead to this point
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

function find_intersections(path1::Path, path2::Path)::Array{Intersection}
    intersections = []
    path1_dist = 0
    for line1 in path1.lines
        path2_dist = 0
        path1_dist += length(line1)
        for line2 in path2.lines
            path2_dist += length(line2)
            intersect = intersection(line1, line2)
            if intersect != nothing
                # subtract the distance to the ends of the lines that intersected to get the total distance
                total_dist = path1_dist + path2_dist - distance(intersect, line1.b) - distance(intersect, line2.b)
                push!(intersections, Intersection(intersect, total_dist))
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

paths = generate_map(readlines())
intersections = find_intersections(paths[1], paths[2])
sort!(intersections, by=i -> i.steps)
filter!(i -> i.point != Point(0,0), intersections) # remove origin point
closest = intersections[1]

println("Fewest steps is $(closest.steps)")
