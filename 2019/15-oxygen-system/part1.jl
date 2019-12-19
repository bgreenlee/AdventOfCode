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
#    println("moved to $(robot.position), status=$status")
    status
end

function display(robot)
#    Intcode.Display.goto(1,1)
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
function neighbors(robot)
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

function search(robot)
    task = @async Intcode.runprogram!(robot.computer)
    start = robot.position
    queue = [start]
    discovered = Set([start])
    parent = Dict()
    step = 0
    while !isempty(queue) && !istaskdone(task)
        # debugging stuff for stepping through
        # display(robot)
        # println("position: $(robot.position)")
        # println("queue: $queue")
        # readline()

        nextcell = popfirst!(queue)
        status = move!(robot, nextcell)

        if status == -1 && nextcell != robot.position # not adjacent and not our current position
            # println("backtracking to $nextcell")
            # put it back on the queue
            pushfirst!(queue, nextcell)
            found = false
            while !found && robot.position != start
                back = parent[robot.position]
                # println("moving to $back")
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
        elseif status == 2
            break # found the goal
        end

        for cell in neighbors(robot)
            if !(cell in discovered)
                push!(discovered, cell)
                parent[cell] = robot.position
                push!(queue, cell)
            end
        end
    end
    # calculate the path back
    p = robot.position
    pathback = [p]
    while (p = parent[p]) != start
        pushfirst!(pathback, p)
    end
    pathback
end

program = read(ARGS[1], String)
robot = Robot(program)
path = search(robot)
display(robot)
println(length(path))