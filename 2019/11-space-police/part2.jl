#!/usr/bin/env julia

include("intcode/intcode.jl")

mutable struct Point
    x
    y
end
Base.copy(p::Point) = Point(p.x, p.y)
Base.hash(p::Point) = hash((p.x, p.y))
Base.isequal(p1::Point, p2::Point) = (p1.x, p1.y) == (p2.x, p1.y)

@enum Direction UP RIGHT DOWN LEFT

mutable struct Robot
    position::Point
    direction::Direction
    computer::Intcode.Computer
end

# move the robot forward in the direction it is facing
function move!(robot)
    if robot.direction == UP
        robot.position.y -= 1
    elseif robot.direction == RIGHT
        robot.position.x += 1
    elseif robot.direction == DOWN
        robot.position.y += 1
    else
        robot.position.x -= 1
    end
    #println("robot at $(robot.position) facing $(robot.direction)")
end

function turn_right!(robot)
    new_direction = (Int(robot.direction) + 1) % 4
    robot.direction = Direction(new_direction)
    move!(robot)
end

function turn_left!(robot)
    new_direction = (Int(robot.direction) + 3) % 4 # three rights make a left, and this keeps us from going negative
    robot.direction = Direction(new_direction)
    move!(robot)
end

function paint!(hull, robot)
    @async Intcode.runprogram!(robot.computer)
    while isopen(robot.computer.output)
        # give the robot the color at the current position
        # I get the wrong answer if I use robot.position directly as they key
        # in the hull dict, and I can't figure out why
        rpos = (robot.position.x, robot.position.y)
        put!(robot.computer.input, get(hull, rpos, 0))

        color = take!(robot.computer.output)
        hull[rpos] = color
        # println(hull)

        move = take!(robot.computer.output)
        if move == 0
            turn_left!(robot)
        else
            turn_right!(robot)
        end
    end
end

function display_hull(hull)
    (minx, maxx) = extrema(x -> x[1], keys(hull))
    (miny, maxy) = extrema(x -> x[2], keys(hull))
    
    for y in miny:maxy
        for x in minx:maxx
            color = get(hull, (x,y), 0)
            print(color == 0 ? ' ' : '#')
        end
        println()
    end
end

input = ARGS[1]
if isfile(input)
    input = read(input, String)
end

computer = Intcode.Computer()
Intcode.load(computer, input)
robot = Robot(Point(0,0), UP, computer)
hull = Dict((0,0) => 1)
paint!(hull, robot)
num_painted = length(keys(hull))
println("painted $num_painted")
display_hull(hull)
