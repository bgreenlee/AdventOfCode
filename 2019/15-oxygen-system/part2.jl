#!/usr/bin/env julia
include("intcode/intcode.jl")

@enum Direction North East South West

# mapping from our ordering to what the computer expects
global const movementcmd = Dict(North => 1, South => 2, West  => 3, East  => 4)

global const movements = [[0,-1], [1,0], [0, 1], [-1,0]] # north, east, south, west

mutable struct Robot
    computer::Intcode.Computer
    maze::Dict
    position::Array{Int}

    function Robot(program::String)
        computer = Intcode.Computer()
        Intcode.load!(computer, program)
        initialposition = [0,0]
        maze = Dict(initialposition => 1)
        new(computer, maze, initialposition)
    end
end

currentmazepos(robot) = robot.maze[robot.position]
opposite(d::Direction) = Direction((Int(d) + 2) % 4)
isadjacent(p1, p2) = (p1 - p2) in movements

# helper function to move the robot to an [hopefully] adjacent position
function move!(robot::Robot, position::Array{Int})
    movement = position - robot.position
    idx = findfirst(m -> m == movement, movements)
    if isnothing(idx)
        return -1 # Not adjacent
    end
    move!(robot, Direction(idx-1))
end

function move!(robot::Robot, direction::Direction)
    put!(robot.computer.input, movementcmd[direction])
    status = take!(robot.computer.output)
    if status != 0 # move robot
        robot.position += movements[Int(direction)+1]
        robot.maze[robot.position] = status
    else
        robot.maze[robot.position + movements[Int(direction)+1]] = 0
    end
    status
end

function display(robot)
    (minx, maxx) = extrema(x -> x[1], keys(robot.maze))
    (miny, maxy) = extrema(x -> x[2], keys(robot.maze))
    
    tiles = ['█', ' ', '⛄']
    for y in miny:maxy
        for x in minx:maxx
            if [x,y] == robot.position
                print('🤖')
            else
                tile = get(robot.maze, [x,y], 1)
                print(tiles[tile+1])
            end
        end
        println()
    end
end

# return a list of positions that the robot can move to
function findneighbors!(robot)
    neighbors = []
    for d in [North, East, South, West]
        status = move!(robot, d)
        if status != 0
            push!(neighbors, robot.position)
            move!(robot, opposite(d)) # move back
        end
    end
    neighbors
end

function generatemaze!(robot)
    task = @async Intcode.runprogram!(robot.computer)
    start = robot.position
    queue = [start]
    discovered = Set([start])
    parent = Dict()
    while !isempty(queue) && !istaskdone(task)
        nextcell = popfirst!(queue)
        status = move!(robot, nextcell)

        if status == -1 && nextcell != robot.position # not adjacent and not our current position
            # put it back on the queue
            pushfirst!(queue, nextcell)
            found = false
            while !found && robot.position != start
                back = parent[robot.position]
                status = move!(robot, back)
                # see if the robot is back on the path to the next cell in the queue
                p = nextcell
                pathback = []
                while (p = parent[p]) != start
                    if p == robot.position
                        found = true
                        break
                    else
                        pushfirst!(pathback, p)
                    end
                end

                if found
                    for cell in pathback
                        move!(robot, cell)
                    end
                end
            end
            continue
        end

        for cell in findneighbors!(robot)
            if !(cell in discovered)
                push!(discovered, cell)
                parent[cell] = robot.position
                push!(queue, cell)
            end
        end
    end
end

function freeneighbors(cell, maze)
    (x,y) = cell
    [c for c in [[x,y-1], [x+1,y], [x,y+1], [x-1,y]] if maze[c] == 1]
end

function timeflood(robot)
    # get position of oxygen sensor (probably not necessary, but ¯\_(ツ)_/¯)
    start = robot.position # need any default
    for (k,v) in robot.maze
        if v == 2
            start = k
            break
        end
    end
    robot.maze[start] = 3 # oxygen
    min = 0
    mazevolume = length([k for (k,v) in robot.maze if v != 0]) 
    while true
        o2cells = [k for (k,v) in robot.maze if v == 3]
        if length(o2cells) == mazevolume
            break
        end
        for cell in o2cells
            for neighbor in freeneighbors(cell, robot.maze)
                robot.maze[neighbor] = 3
            end
        end
        min += 1
    end
    min
end

program = read(ARGS[1], String)
robot = Robot(program)
generatemaze!(robot)
#display(robot)
min = timeflood(robot)
println("minutes to flood: $min")

