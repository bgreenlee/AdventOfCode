
# split the opcode into (opcode, param_modes)
function splitopcode(opcode::Int)
    max_params = 3
    opcode_str = string(opcode, pad=max_params+2)
    code = parse(Int, opcode_str[end-1:end])
    param_modes = reverse(map(c -> parse(Int, c), collect(opcode_str[1:3])))
    code, param_modes
end

struct Operation
    code::Int
    pmodes::Array{Int}
    Operation(opcode::Int) = new(splitopcode(opcode)...)
end

function runprogram!(mem::Memory, input_channel, output_channel)
    ptr = 1
    while ptr <= length(mem)
        op = Operation(readmem(mem, ptr))
        params = getparams(mem, ptr, op.pmodes, 2)
        if op.code == 1 # add
            writemem!(mem, ptr+3, op.pmodes[3], params[1] + params[2])
            ptr += 4
        elseif op.code == 2 # multiply
            writemem!(mem, ptr+3, op.pmodes[3], params[1] * params[2])
            ptr += 4
        elseif op.code == 3 # input
            writemem!(mem, ptr+1, op.pmodes[1], take!(input_channel))
            ptr += 2
        elseif op.code == 4 # output
            put!(output_channel, params[1])
            ptr += 2
        elseif op.code == 5 # jump-if-true
            ptr = params[1] == 0 ? ptr + 3 : params[2] + 1
        elseif op.code == 6 # jump-if-false
            ptr = params[1] == 0 ? params[2] + 1 : ptr + 3
        elseif op.code == 7 # less than
            writemem!(mem, ptr+3, op.pmodes[3], params[1] < params[2] ? 1 : 0)
            ptr += 4
        elseif op.code == 8 # equals
            writemem!(mem, ptr+3, op.pmodes[3], params[1] == params[2] ? 1 : 0)
            ptr += 4
        elseif op.code == 9 # adjust relative base
            mem.relbase += params[1]
            ptr += 2
        elseif op.code == 99
            close(output_channel)
            break
        else
            print("unknown opcode: $(mem[ptr]) at #$ptr\n")
        end
    end
end
