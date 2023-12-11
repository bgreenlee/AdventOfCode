#!/usr/bin/env elixir

defmodule Universe do
  defstruct map: %{}, height: 0, width: 0

  # parse the map into a Map of {x,y} => true for each galaxy
  def parse_map(input, expansion) do
    # create base map
    lines = String.split(input, "\n", trim: true)
    width = String.length(Enum.at(lines, 0))
    height = Enum.count(lines)

    map = lines
    |> Enum.with_index()
    |> Enum.map(fn {line, y} ->
      line
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {char, x} -> {{x, y}, char == "#"} end)
      |> Enum.reject(fn {_, val} -> !val end)
    end)
    |> List.flatten()
    |> Map.new()

    # find the empty rows and columns
    empty_rows = Enum.filter(0..(height - 1), fn y ->
      Enum.all?(0..(width - 1), fn x -> map[{x, y}] == nil end)
    end)
    empty_columns = Enum.filter(0..(width - 1), fn x ->
      Enum.all?(0..(height - 1), fn y -> map[{x, y}] == nil end)
    end)

    # expand the map
    map = Map.new(map, fn {{x, y}, char} ->
      {{x + Enum.count(empty_columns, fn c -> c < x end) * (expansion - 1),
        y + Enum.count(empty_rows, fn r -> r < y end) * (expansion - 1)}, char}
    end)

    height = height + length(empty_rows)
    width = width + length(empty_columns)

    {map, height, width}
  end

  def new(input, expansion) do
    {map, height, width} = parse_map(input, expansion)
    %__MODULE__{map: map, height: height, width: width}
  end
end

defmodule Main do
  def solve(input, expansion) do
    universe = Universe.new(input, expansion)
    # generate list of every pair of points in the map
    Map.keys(universe.map)
    |> Enum.map(fn p1 ->
      Map.keys(universe.map)
      |> Enum.map(fn p2 -> {p1, p2} end)
      # remove pairs where the second point is "behind" or equal to the first point
      |> Enum.reject(fn {{x1, y1}, {x2, y2}} -> y2 * universe.width + x2 <= y1 * universe.width + x1 end)
    end)
    |> List.flatten()
    # sum the distance between each pair of points
    |> Enum.map(fn {{x1, y1}, {x2, y2}} -> abs(x1 - x2) + abs(y1 - y2) end)
    |> Enum.sum()
  end
end

input = IO.read(:stdio, :all)

{μsec, result} = :timer.tc(fn -> Main.solve(input, 2) end)
IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
{μsec, result} = :timer.tc(fn -> Main.solve(input, 1000000) end)
IO.puts("Part 2: #{result} (#{μsec / 1000} ms)")
