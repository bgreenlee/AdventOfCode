#!/usr/bin/env elixir

defmodule Main do
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [dir, dist, _color] = String.split(line, " ", trim: true)
      {dir, String.to_integer(dist)}
    end)
  end

  def parse_part2_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [_, hex] = Regex.run(~r/#(\w+)/, line)
      dist = String.to_integer(String.slice(hex, 0..4), 16)
      dir = Enum.at(["R","D","L","U"], String.to_integer(String.last(hex)))
      {dir, dist}
    end)
  end

  def generate_map(directions) do
    directions
    # |> IO.inspect()
    |> Enum.reduce({%{}, {0, 0}}, fn {dir, dist}, {map, {x, y}} ->
      {nx, ny} = case dir do
        "U" -> {x, y - dist}
        "D" -> {x, y + dist}
        "L" -> {x - dist, y}
        "R" -> {x + dist, y}
      end
      new_map = Enum.reduce(x..nx, map, fn x, map ->
        Enum.reduce(y..ny, map, fn y, map ->
          Map.put(map, {x, y}, true)
        end)
      end)
      {new_map, {nx, ny}}
    end)
    |> elem(0)
  end

  def flood_fill(map, {x, y}) do
    if Map.has_key?(map, {x, y}) do
      map
    else
      flood_fill(Map.put(map, {x, y}, true), {x - 1, y})
      |> flood_fill({x + 1, y})
      |> flood_fill({x, y - 1})
      |> flood_fill({x, y + 1})
    end
  end

  def flood_fill_with_border(map, {x, y}, xmin, xmax, ymin, ymax) do
    if Map.has_key?(map, {x, y}) or x < xmin or x > xmax or y < ymin or x > ymax do
      map
    else
      flood_fill_with_border(Map.put(map, {x, y}, "x"), {x - 1, y}, xmin, xmax, ymin, ymax)
      |> flood_fill_with_border({x + 1, y}, xmin, xmax, ymin, ymax)
      |> flood_fill_with_border({x, y - 1}, xmin, xmax, ymin, ymax)
      |> flood_fill_with_border({x, y + 1}, xmin, xmax, ymin, ymax)
    end
  end

  def part1(input) do
    input
    |> parse_input()
    |> generate_map()
    |> flood_fill({1, 1})
    |> Enum.count()
  end

  def part2(input) do
    map = input
    |> parse_part2_input()
    |> IO.inspect(limit: :infinity)
    # |> generate_map()
    # # get xmin, xmax, ymin, ymax of map
    # {xmin, xmax, ymin, ymax} = map
    # |> Enum.reduce({0, 0, 0, 0}, fn {{x, y}, _}, {xmin, xmax, ymin, ymax} ->
    #   {min(x, xmin), max(x, xmax), min(y, ymin), max(y, ymax)}
    # end)

    # outer_count = map
    # |> flood_fill_with_border({-1, -1}, xmin-1, xmax+1, ymin-1, ymax+1)
    # |> Enum.count(fn _,v -> v == "o" end)
    # |> IO.inspect()

    # (xmax - xmin + 2) * (ymax - ymin + 2) - outer_count
  end
end

input = IO.read(:stdio, :all)

{μsec, result} = :timer.tc(fn -> Main.part1(input) end)
IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
{μsec, result} = :timer.tc(fn -> Main.part2(input) end)
IO.puts("Part 2: #{result} (#{μsec / 1000} ms)")
