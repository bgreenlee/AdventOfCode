import Base.length

mutable struct Memory
    data::Array{Int}
    relbase::Int
    Memory(memsize::Int) = new(zeros(Int, memsize), 0)
end

load(mem::Memory, program) = mem.data[1:length(program)] = program
length(mem::Memory) = length(mem.data)

function readmem(mem::Memory, ptr, mode=1)
    if mode == 0 # position mode
        mem.data[mem.data[ptr]+1]
    elseif mode == 1 # absolute mode
        mem.data[ptr]
    else # relative mode
        mem.data[mem.data[ptr]+1+mem.relbase]
    end
end

function writemem!(mem::Memory, ptr, mode, value)
    relative = mode == 2 ? mem.relbase : 0
    mem.data[mem.data[ptr]+1+relative] = value
end
    
function getparams(mem::Memory, ptr, modes, count)
    [readmem(mem, ptr+i, modes[i]) for i in 1:count]
end