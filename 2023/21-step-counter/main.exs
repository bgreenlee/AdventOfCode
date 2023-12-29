#!/usr/bin/env elixir

defmodule Main do

  # parse the map into a Map of {x,y} => char
  def parse_map(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {line, y} ->
      line
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {char, x} -> {{x, y}, char} end)
    end)
    |> List.flatten()
    |> Map.new()
  end

  def neighbors(map, {x, y}) do
    [
      {x, y - 1},
      {x + 1, y},
      {x, y + 1},
      {x - 1, y},
    ]
    |> Enum.filter(fn {x, y} -> map[{x, y}] != "#" and map[{x, y}] != nil end)
  end

  # simplified A* to find distances to all points
  def find_distances(map, open_set, g_score) do
    if MapSet.size(open_set) == 0 do
      g_score
    else
      {current, dist} = Enum.min_by(open_set, fn {_, p} -> p end) # faster w/ a priority queue, but this is good enough
      open_set = MapSet.delete(open_set, {current, dist})
      neighbors = neighbors(map, current)
      {open_set, g_score} =
        Enum.reduce(neighbors, {open_set, g_score}, fn neighbor, {open_set, g_score} ->
          tentative_g_score = g_score[current] + 1

          if tentative_g_score < Map.get(g_score, neighbor, :infinity) do
            g_score = Map.put(g_score, neighbor, tentative_g_score)
            open_set = MapSet.put(open_set, {neighbor, tentative_g_score})
            {open_set, g_score}
          else
            {open_set, g_score}
          end
        end)
      find_distances(map, open_set, g_score)
    end
  end

  def part1(input, step_target) do
    map = parse_map(input)
    start = Enum.find_value(map, fn {k, v} -> v == "S" && k end)

    find_distances(map, MapSet.new([{start, 0}]), %{start => 0})
    |> Enum.count(fn {_, v} -> v <= step_target and rem(v, 2) == rem(step_target, 2) end)
  end

  # Much help from https://github.com/villuna/aoc23/wiki/A-Geometric-solution-to-advent-of-code-2023,-day-21
  def part2(input, step_target) do
    map = parse_map(input)
    width = Enum.reduce(map, 0, fn {{x, _}, _}, width -> max(x, width) end) + 1
    half_width = div(width, 2)

    start = Enum.find_value(map, fn {k, v} -> v == "S" && k end)

    map = find_distances(map, MapSet.new([{start, 0}]), %{start => 0})

    even_full = Enum.count(map, fn {_, v} -> rem(v, 2) == 0 end)
    odd_full = Enum.count(map, fn {_, v} -> rem(v, 2) == 1 end)
    even_corners = Enum.count(map, fn {_, v} -> v > half_width and rem(v, 2) == 0 end)
    odd_corners = Enum.count(map, fn {_, v} -> v > half_width and rem(v, 2) == 1 end)

    n = div(step_target - half_width, width)
    (n + 1) * (n + 1) * odd_full + n * n * even_full - (n + 1) * odd_corners + n * even_corners
  end
end

input = IO.read(:stdio, :all)

{μsec, result} = :timer.tc(fn -> Main.part1(input, 64) end)
IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
{μsec, result} = :timer.tc(fn -> Main.part2(input, 26501365) end)
IO.puts("Part 2: #{result} (#{μsec / 1000} ms)")
