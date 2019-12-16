#!/usr/bin/env julia

struct Position x; y; z end
struct Velocity x; y; z end

Base.:+(p::Position, v::Velocity) = Position(p.x + v.x, p.y + v.y, p.z + v.z)
Base.:-(p::Position, v::Velocity) = Position(p.x - v.x, p.y - v.y, p.z - v.z)
Base.:+(v1::Velocity, v2::Velocity) = Velocity(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
Base.:+(v1::Velocity, v2::Velocity) = Velocity(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
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

input = readlines(ARGS[1])
numsteps = parse(Int, ARGS[2])

moons = [Moon(line) for line in input]

for t in 1:numsteps
    run_step!(moons)
end
total_energy = sum(energy, moons)
println("Total energy: $total_energy")
