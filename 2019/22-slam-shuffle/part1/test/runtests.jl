include("../src/shuffle.jl")
using Test

@testset "empty program" begin
    cards = shuffle([], 5)
    @test cards == [0, 1, 2, 3, 4]
end

@testset "deal into new stack" begin
    cards = shuffle(["deal into new stack"], 5)
    @test cards == [4, 3, 2, 1, 0]

    cards = shuffle(["deal into new stack", "deal into new stack"], 5)
    @test cards == [0, 1, 2, 3, 4]
end

@testset "cut cards" begin
    cards = shuffle(["cut 2"], 5)
    @test cards == [2, 3, 4, 0, 1]

    cards = shuffle(["cut -2"], 5)
    @test cards == [3, 4, 0, 1, 2]
end

@testset "deal with increment" begin
    cards = shuffle(["deal with increment 3"], 10)
    @test cards == [0, 7, 4, 1, 8, 5, 2, 9, 6, 3]
end

@testset "position" begin
    cards = shuffle([], 10)
    @test position(cards, 5) == 5
end

@testset "integration" begin
    program = [
        "deal with increment 7",
        "deal into new stack",
        "deal into new stack",
    ]
    cards = shuffle(program, 10)
    @test cards == [0, 3, 6, 9, 2, 5, 8, 1, 4, 7]

    program = [
        "cut 6",
        "deal with increment 7",
        "deal into new stack",
    ]
    cards = shuffle(program, 10)
    @test cards == [3, 0, 7, 4, 1, 8, 5, 2, 9, 6]


    program = [
        "deal with increment 7",
        "deal with increment 9",
        "cut -2",
    ]
    cards = shuffle(program, 10)
    @test cards == [6, 3, 0, 7, 4, 1, 8, 5, 2, 9]

    program = [
        "deal into new stack",
        "cut -2",
        "deal with increment 7",
        "cut 8",
        "cut -4",
        "deal with increment 7",
        "cut 3",
        "deal with increment 9",
        "deal with increment 3",
        "cut -1",
    ]
    cards = shuffle(program, 10)
    @test cards == [9, 2, 5, 8, 1, 4, 7, 0, 3, 6]
end


