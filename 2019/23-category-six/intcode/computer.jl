include("memory.jl")

const DEFAULT_MEMSIZE = 1024*1024
const DEFAULT_INPUT_CHANNEL_SIZE = 4096
const DEFAULT_OUTPUT_CHANNEL_SIZE = 4096

mutable struct Computer
    memory::Memory
    input::Channel
    output::Channel
    Computer(memsize=DEFAULT_MEMSIZE,
             input=Channel(DEFAULT_INPUT_CHANNEL_SIZE),
             output=Channel(DEFAULT_OUTPUT_CHANNEL_SIZE)) =
        new(Memory(memsize), input, output)
end

function load!(computer::Computer, input)
    program = read_program(input)
    load(computer.memory, program)
end

function runprogram!(computer)
    runprogram!(computer.memory, computer.input, computer.output)
end
