#!/usr/bin/env elixir

defmodule Platform do
  defstruct balls: %{}, blocks: %{}, height: 0, width: 0

  def parse_platform(input) do
    lines = String.split(input, "\n", trim: true)
    width = String.length(Enum.at(lines, 0))
    height = Enum.count(lines)

    {balls, blocks} =
      lines
      |> Enum.with_index()
      |> Enum.map(fn {line, y} ->
        line
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.map(fn {char, x} ->
          point = {x, y}
          {point, char == "O", char == "#"}
        end)
      end)
      |> List.flatten()
      |> Enum.reject(fn {_, ball, block} -> not ball and not block end)
      |> Enum.split_with(fn {_, ball, _} -> ball end)

    balls = balls |> Enum.map(fn {point, _, _} -> {point, true} end) |> Map.new()
    blocks = blocks |> Enum.map(fn {point, _, _} -> {point, true} end) |> Map.new()

    {balls, blocks, height, width}
  end

  def tilt_north(platform) do
    balls =
      platform.balls
      |> Map.to_list()
      |> Enum.sort()
      |> Enum.reduce(%{}, fn {{x, y}, _}, acc ->
        new_y =
          if y == 0 do
            0
          else
            blocker =
              Enum.find((y - 1)..0, fn y ->
                Map.get(acc, {x, y}, false) or Map.get(platform.blocks, {x, y}, false)
              end)

            if blocker == nil, do: 0, else: blocker + 1
          end

        Map.put(acc, {x, new_y}, true)
      end)

    %__MODULE__{platform | balls: balls}
  end

  def tilt_west(platform) do
    balls =
      platform.balls
      |> Map.to_list()
      |> Enum.sort()
      |> Enum.reduce(%{}, fn {{x, y}, _}, acc ->
        new_x =
          if x == 0 do
            0
          else
            blocker =
              Enum.find((x - 1)..0, fn x ->
                Map.get(acc, {x, y}, false) or Map.get(platform.blocks, {x, y}, false)
              end)

            if blocker == nil, do: 0, else: blocker + 1
          end

        Map.put(acc, {new_x, y}, true)
      end)

    %__MODULE__{platform | balls: balls}
  end

  def tilt_south(platform) do
    balls =
      platform.balls
      |> Map.to_list()
      |> Enum.sort(:desc)
      |> Enum.reduce(%{}, fn {{x, y}, _}, acc ->
        new_y =
          if y == platform.height - 1 do
            platform.height - 1
          else
            blocker =
              Enum.find((y + 1)..(platform.height - 1), fn y ->
                Map.get(acc, {x, y}, false) or Map.get(platform.blocks, {x, y}, false)
              end)

            if blocker == nil, do: platform.height - 1, else: blocker - 1
          end

        Map.put(acc, {x, new_y}, true)
      end)

    %__MODULE__{platform | balls: balls}
  end

  def tilt_east(platform) do
    balls =
      platform.balls
      |> Map.to_list()
      |> Enum.sort(:desc)
      |> Enum.reduce(%{}, fn {{x, y}, _}, acc ->
        new_x =
          if x == platform.width - 1 do
            platform.width - 1
          else
            blocker =
              Enum.find((x + 1)..(platform.width - 1), fn x ->
                Map.get(acc, {x, y}, false) or Map.get(platform.blocks, {x, y}, false)
              end)

            if blocker == nil, do: platform.width - 1, else: blocker - 1
          end

        Map.put(acc, {new_x, y}, true)
      end)

    %__MODULE__{platform | balls: balls}
  end

  def cycle(platform) do
    platform
    |> tilt_north()
    |> tilt_west()
    |> tilt_south()
    |> tilt_east()
  end

  def score(platform) do
    platform.balls
    |> Map.keys()
    |> Enum.reduce(0, fn {_, y}, acc -> acc + platform.height - y end)
  end

  def new(input) do
    {balls, blocks, height, width} = parse_platform(input)
    %__MODULE__{balls: balls, blocks: blocks, height: height, width: width}
  end
end

defimpl String.Chars, for: Platform do
  def to_string(platform) do
    Enum.reduce(0..(platform.height - 1), "", fn y, acc ->
      Enum.reduce(0..(platform.width - 1), acc, fn x, acc ->
        cond do
          Map.get(platform.blocks, {x, y}, false) -> acc <> "#"
          Map.get(platform.balls, {x, y}, false) -> acc <> "O"
          true -> acc <> "."
        end
      end)
      |> Kernel.<>("\n")
    end)
  end
end

defmodule Main do
  def part1(input) do
    Platform.new(input)
    |> Platform.tilt_north()
    |> Platform.score()
  end

  def part2(input, target \\ 1_000_000_000) do
    platform = Platform.new(input)

    # calculate scores until we detect a cycle
    {platform, seen, i} =
      Enum.reduce_while(1..target, {platform, %{}, 0}, fn i, acc ->
        {platform, seen, _} = acc
        platform = platform |> Platform.cycle()
        balls = platform.balls |> Map.keys() |> Enum.sort()

        if seen[balls] != nil do
          {:halt, {platform, seen, i}}
        else
          {:cont, {platform, Map.put(seen, balls, {i, Platform.score(platform)}), i}}
        end
      end)

    # get the cycle start and calculate cycle length
    balls_key = platform.balls |> Map.keys() |> Enum.sort()
    {cycle_start, _score} = seen[balls_key]
    cycle_length = i - cycle_start
    offset = cycle_start + rem(target - cycle_start, cycle_length)

    # find offset in seen keys to get score
    Map.values(seen) |> Enum.find(fn {i, _score} -> i == offset end) |> elem(1)
  end
end

input = IO.read(:stdio, :all)

{μsec, result} = :timer.tc(fn -> Main.part1(input) end)
IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
{μsec, result} = :timer.tc(fn -> Main.part2(input) end)
IO.puts("Part 2: #{result} (#{μsec / 1000} ms)")
