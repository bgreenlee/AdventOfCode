#!/usr/bin/env julia

include("intcode/intcode.jl")

mutable struct Node
    address::Int
    computer::Intcode.Computer

    function Node(address, program::String)
        computer = Intcode.Computer()
        Intcode.load!(computer, program)
        put!(computer.input, address)
        println("Starting node $address...")
        @async Intcode.runprogram!(computer)
        new(address, computer)
    end
end

mutable struct Nat
    x
    y
    input::Channel
end

function run(program)
    nodes = [Node(i, program) for i in 0:49]
    # start Nat
    nat = Nat(-1, -1, Channel{Int}(2))
    @async begin
        while true
            nat.x = take!(nat.input)
            nat.y = take!(nat.input)
            println("NAT: received ($(nat.x), $(nat.y))")
        end
    end

    # async loop for checking for idle
    @async begin
        lasty = -1
        while true
            idle = all([!isready(n.computer.input) for n in nodes])
            if idle && nat.y != -1
                println("NAT: network idle, sending ($(nat.x), $(nat.y)) => 0")
                put!(nodes[1].computer.input, nat.x)
                put!(nodes[1].computer.input, nat.y)
                if nat.y == lasty
                    println("Finished: $(nat.y)")
                    return
                end
                lasty = nat.y
            end
            sleep(1)
        end
    end

    while true
        for node in nodes
            put!(node.computer.input, -1)
            if isready(node.computer.output)
                addr = take!(node.computer.output)
                x = take!(node.computer.output)
                y = take!(node.computer.output)
                println("$(node.address): ($x, $y) => $addr")
                if addr == 255
                    put!(nat.input, x)
                    put!(nat.input, y)
                else
                    put!(nodes[addr+1].computer.input, x)
                    put!(nodes[addr+1].computer.input, y)
                end
            end
        end
        sleep(0.1)
    end
end

program = string(readchomp(ARGS[1]))
run(program)
