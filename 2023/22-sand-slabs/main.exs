#!/usr/bin/env elixir

defmodule Main do
  Code.require_file("brick.exs")

  def parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line -> Brick.new(line) end)
    |> Enum.sort_by(fn brick -> {x, y, z} = brick.start; {z, y, x} end)
  end

  def part1(input) do
    bricks = input
    |> parse_input()
    |> Brick.drop_bricks()

    # build graph of bricks to show which bricks are supported by which other bricks
    graph = bricks
    |> Enum.map(fn brick ->
      {brick, %{
        :above => Brick.bricks_above(bricks, brick),
        :below => Brick.bricks_below(bricks, brick)
      }}
    end)
    |> Map.new()

    # count the bricks where all of the above bricks have more than one supporting brick
    graph
    |> Enum.count(fn {_brick, %{above: above, below: _}} ->
      Enum.all?(above, fn b -> Enum.count(graph[b][:below]) > 1 end)
    end)
  end

  # recursively count the number of bricks that would fall if the given brick were disintegrated
  def count_fallen_bricks(graph, brick, all_fallen \\ MapSet.new()) do
    # IO.inspect(brick, label: "brick")
    falling = Enum.filter(graph[brick][:above], fn b ->
      Enum.all?(graph[b][:below], fn b2 -> b2 == brick or MapSet.member?(all_fallen, b2) end)
    end)
    all_fallen = MapSet.union(all_fallen, MapSet.new(falling))
    # IO.inspect(falling, label: "falling")
    Enum.reduce(falling, all_fallen, fn b, acc -> MapSet.union(acc, count_fallen_bricks(graph, b, all_fallen)) end)
  end

  def part2(input) do
    bricks = input
    |> parse_input()
    |> Brick.drop_bricks()

    # build graph of bricks to show which bricks are supported by which other bricks
    graph = bricks
    |> Enum.map(fn brick ->
      {brick, %{
        :above => Brick.bricks_above(bricks, brick),
        :below => Brick.bricks_below(bricks, brick)
      }}
    end)
    |> Map.new()

    # count the number of bricks that would fall if each brick were disintegrated
    graph
    |> Enum.map(fn {brick, _} -> count_fallen_bricks(graph, brick) |> MapSet.size() end)
    # |> IO.inspect(limit: :infinity)
    |> Enum.sum()
  end
end

input = IO.read(:stdio, :all)

{μsec, result} = :timer.tc(fn -> Main.part1(input) end)
IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
{μsec, result} = :timer.tc(fn -> Main.part2(input) end)
IO.puts("Part 2: #{result} (#{μsec / 1000} ms)")
