#!/usr/bin/env elixir

defmodule Main do
   # generate a list of vertices given the directions
  def generate_vertices(directions) do
    directions
    # |> IO.inspect()
    |> Enum.reduce({{0, 0}, []}, fn {dir, dist}, {{x, y}, vertices} ->
      {nx, ny} = case dir do
        "U" -> {x, y - dist}
        "D" -> {x, y + dist}
        "L" -> {x - dist, y}
        "R" -> {x + dist, y}
      end
      {{nx, ny}, [{nx, ny} | vertices]}
    end)
    |> elem(1)
  end

  # given a list of vertices, calculate the interior area using the Shoelace formula
  def calculate_interior_area(vertices) do
    vertices
    |> Enum.chunk_every(2, 1, vertices)
    |> Enum.map(fn [{x1, y1}, {x2, y2}] ->
      x1 * y2 - x2 * y1
    end)
    |> Enum.sum()
    |> abs()
    |> div(2)
  end

  def calculate_area(directions) do
    area = directions
    |> generate_vertices()
    |> calculate_interior_area()

    # we need to add in half the perimeter (plus one) (Pick's theorem)
    perimeter = directions
    |> Enum.reduce(0, fn {_, dist}, acc -> acc + dist end)

    area + div(perimeter, 2) + 1
  end

  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [dir, dist, _color] = String.split(line, " ", trim: true)
      {dir, String.to_integer(dist)}
    end)
    |> calculate_area()
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [_, hex] = Regex.run(~r/#(\w+)/, line)
      dist = String.to_integer(String.slice(hex, 0..4), 16)
      dir = Enum.at(["R","D","L","U"], String.to_integer(String.last(hex)))
      {dir, dist}
    end)
    |> calculate_area()
  end
end

input = IO.read(:stdio, :all)

{μsec, result} = :timer.tc(fn -> Main.part1(input) end)
IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
{μsec, result} = :timer.tc(fn -> Main.part2(input) end)
IO.puts("Part 2: #{result} (#{μsec / 1000} ms)")
