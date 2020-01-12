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

function run(program)
    nodes = [Node(i, program) for i in 0:49]

    done = false
    while !done
        for node in nodes
            put!(node.computer.input, -1)
            if isready(node.computer.output)
                addr = take!(node.computer.output)
                x = take!(node.computer.output)
                y = take!(node.computer.output)
                println("Node $(node.address): ($x, $y) => $addr")
                if addr == 255
                    println("y = $y")
                    done = true
                    break
                end
                put!(nodes[addr+1].computer.input, x)
                put!(nodes[addr+1].computer.input, y)
            end
        end
    end
end

program = string(readchomp(ARGS[1]))
run(program)
