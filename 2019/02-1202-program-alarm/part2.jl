#!env julia

# read the Intcode program from stdin and return an array of Ints
function readprogram()
    opcodes = split(readline(), ",")
    opcodes = map(n -> tryparse(Int, n), opcodes)
    filter(n -> n != nothing, opcodes) # remove any bad input
end

function findinputs(program) 
    for n = 0:99
        for v = 0:99
            mem = copy(program)
            # patch per instructions
            mem[2] = n
            mem[3] = v
            # Julia uses 1-based indexing
            ptr = 1

            while ptr <= length(mem)
                # global ptr
                if mem[ptr] == 1
                    mem[mem[ptr+3]+1] = mem[mem[ptr+1]+1] + mem[mem[ptr+2]+1]
                    ptr += 4
                elseif mem[ptr] == 2
                    mem[mem[ptr+3]+1] = mem[mem[ptr+1]+1] * mem[mem[ptr+2]+1]
                    ptr += 4
                elseif mem[ptr] == 99
                    break
                else
                    #print("unknown opcode: $(mem[ptr]) at #$ptr\n")
                    break
                end
            end

            if mem[1] == 19690720
                return n * 100 + v
            end
        end
    end
end

program = readprogram()
result = findinputs(program)

print(result,"\n")

