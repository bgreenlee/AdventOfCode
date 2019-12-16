#!/usr/bin/env julia

struct Position x; y; z end
struct Velocity x; y; z end

Base.:+(p::Position, v::Velocity) = Position(p.x + v.x, p.y + v.y, p.z + v.z)
Base.:-(p::Position, v::Velocity) = Position(p.x - v.x, p.y - v.y, p.z - v.z)
Base.:+(v1::Velocity, v2::Velocity) = Velocity(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
Base.:+(v1::Velocity, v2::Velocity) = Velocity(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
Base.iszero(v::Velocity) = v.x == 0 && v.y == 0 && v.z == 0
Base.copy(p::Position) = Position(p.x, p.y, p.z)
gravity(a::Position, b::Position) = Velocity(cmp(a.x, b.x), cmp(a.y, b.y), cmp(a.z, b.z))

# Parse an input string in the form "<x=-1, y=0, z=2>"
# and return an array [-1, 0, 2]
function parse_vector(input::String)
    m = match(r"<x=(-?\d+),\s*y=(-?\d+),\s*z=(-?\d+)>", input)
    [parse(Int, n) for n in m.captures]
end

mutable struct Moon
    position::Position
    velocity::Velocity

    Moon(input::String) = new(Position(parse_vector(input)...), Velocity(0,0,0))
end
potential_energy(m::Moon) = abs(m.position.x) + abs(m.position.y) + abs(m.position.z)
kinetic_energy(m::Moon) = abs(m.velocity.x) + abs(m.velocity.y) + abs(m.velocity.z)
energy(m::Moon) = potential_energy(m) * kinetic_energy(m)
Base.hash(m::Moon) = hash((m.position.x, m.position.y, m.position.z, m.velocity.x, m.velocity.y, m.velocity.z))

function apply_gravity!(a::Moon, b::Moon)
    a.velocity += gravity(a.position, b.position)
    b.velocity += gravity(b.position, a.position)
end

apply_velocity!(m::Moon) = m.position += m.velocity

function run_step!(moons)
    # apply gravity
    for i in eachindex(moons)
        for j in i+1:length(moons)
            apply_gravity!(moons[i], moons[j])
        end
    end

    foreach(apply_velocity!, moons)
end

function system_state(moons)::UInt64
    hash(tuple([hash(m) for m in moons]...))
end

function simulate(moons)
    # generate a matrix of initial positions
    initial_positions = zeros(Int, length(moons), 3)
    for i in eachindex(moons)
        p = moons[i].position
        initial_positions[i,:] = [p.x, p.y, p.z]
    end

    t = 0
    (tx, ty, tz) = (0, 0, 0) # time to zero for each axis
    vmatrix = zeros(Int, length(moons), 3) # velocity matrix
    pmatrix = zeros(Int, length(moons), 3) # position matrix
    while true
        t += 1
        run_step!(moons)
        for i in eachindex(moons)
            v = moons[i].velocity
            p = moons[i].position
            vmatrix[i,:] = [v.x, v.y, v.z]
            pmatrix[i,:] = [p.x, p.y, p.z]
        end
        if iszero(vmatrix[:,1]) && pmatrix[:,1] == initial_positions[:,1]
            tx = t
        end
        if iszero(vmatrix[:,2]) && pmatrix[:,2] == initial_positions[:,2]
            ty = t
        end
        if iszero(vmatrix[:,3]) && pmatrix[:,3] == initial_positions[:,3]
            tz = t
        end        
        if all(t -> t > 0, [tx, ty, tz])
            break
        end
    end
    lcm(tx, ty, tz)
end

input = readlines(ARGS[1])

moons = [Moon(line) for line in input]
t = simulate(moons)

println("Looped after $t steps")
