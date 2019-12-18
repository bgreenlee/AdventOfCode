#!/usr/bin/env julia
include("intcode/intcode.jl")

@enum Direction North East South West
@enum Turn Left Straight Right Back

global const movementcmd = Dict(
    North => 1,
    South => 2,
    West  => 3,
    East  => 4,
)
global const movements = [
    [0,-1], # north
    [ 1,0], # east
    [0, 1], # south
    [-1,0], # west
 ]

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

function currentmazepos(robot)
    robot.maze[robot.position]
end

function move!(robot, direction)
#    print("Moving $direction...")
    put!(robot.computer.input, movementcmd[direction])
    status = take!(robot.computer.output)
    if status != 0 # move robot
        robot.position += movements[Int(direction)+1]
        robot.maze[robot.position] = status
#        println("ok")
    else
        robot.maze[robot.position + movements[Int(direction)+1]] = 0
#        println("wall")
    end
    status
end

function turn(t::Turn, facing::Direction)
    if t == Left
        d = Direction((Int(facing) + 3) % 4)
    elseif t == Straight
        d = facing
    elseif t == Right
        d = Direction((Int(facing) + 1 ) % 4)
    elseif t == Back
        d = Direction((Int(facing) + 2) % 4)
    end
#    println("turning $t to $d")
    d
end

# search using left-hand wall (LSRB) algorithm
function search(robot)
    task = @async Intcode.runprogram!(robot.computer)
    path = ""
    facing = North
    steps = 0
    while !istaskdone(task)
#        println("facing $facing")
        if steps % 100 == 0
            display(robot)
            println(path)
        end
        if currentmazepos(robot) == 2
            break # found the goal
        end

        steps += 1
        # if steps > 10
        #     break
        # end

        # see if we can go left
        f = turn(Left, facing)
        if move!(robot, f) != 0
            path *= "L"
            facing = f
            continue
        end

        # try straight
        f = turn(Straight, facing)
        if move!(robot, f) != 0
            path *= "S"
            continue
        end

        # try right
        f = turn(Right, facing)
        if move!(robot, f) != 0
            path *= "R"
            facing = f
            continue
        end

        # back
        f = turn(Back, facing)
        if move!(robot, South) != 0
            path *= "B"
            facing = f
        end
    end
    path
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

# function search(robot)
#     queue = [robot.position]
#     while !isempty(queue)
#         p = popfirst!(queue)
#         if robot.maze[p] == 2 # found the goal
#             return
#         else
#             for p in neighbors(robot.maze, robot.position)
#                 if !haskey(robot.maze, p)
#                     robot.maze[p] = #something
#                     push!(queue, p)
#                 end
#             end
#         end
#     end
# end

program = read(ARGS[1], String)
robot = Robot(program)
path = search(robot)
println("path: $path")