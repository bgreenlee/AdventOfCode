#!/usr/bin/env elixir

defmodule Pattern do
  defstruct points: %{}, height: 0, width: 0, reflection: {}

  # parse the map into a Map of {x,y} => true for each rock
  def parse_pattern(input) do
    lines = String.split(input, "\n", trim: true)
    width = String.length(Enum.at(lines, 0))
    height = Enum.count(lines)

    points =
      lines
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

    {points, height, width}
  end

  # find the reflection, allowing for smudges
  def find_reflection(pattern, smudges_allowed \\ 0) do
    # check for vertical reflection lines first
    # we use the point to the right of the line as the reference point
    vert_x =
      Enum.find(1..(pattern.width - 1), fn x ->
        max_dx = min(x - 1, pattern.width - x - 1)

        mismatch_count =
          for dx <- 0..max_dx do
            Enum.count(0..(pattern.height - 1), fn y ->
              pattern.points[{x - dx - 1, y}] != pattern.points[{x + dx, y}]
            end)
          end
          |> Enum.sum()

        mismatch_count == smudges_allowed
      end)

    if vert_x != nil do
      {:vert, vert_x}
    else
      # check for horizontal reflection lines
      # we use the point below the line as the reference point
      horz_y =
        Enum.find(1..(pattern.height - 1), fn y ->
          max_dy = min(y - 1, pattern.height - y - 1)

          mismatch_count =
            for dy <- 0..max_dy do
              Enum.count(0..(pattern.width - 1), fn x ->
                pattern.points[{x, y - dy - 1}] != pattern.points[{x, y + dy}]
              end)
            end
            |> Enum.sum()

          mismatch_count == smudges_allowed
        end)

      {:horz, horz_y}
    end
  end

  def score({type, midpoint}) do
    case type do
      :vert -> midpoint
      :horz -> midpoint * 100
    end
  end

  def new(input) do
    {points, height, width} = parse_pattern(input)
    %__MODULE__{points: points, height: height, width: width}
  end
end

defmodule Main do
  def parse_input(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn pattern -> Pattern.new(pattern) end)
  end

  def part1(patterns) do
    patterns
    |> Enum.map(fn pattern -> pattern |> Pattern.find_reflection() |> Pattern.score() end)
    |> Enum.sum()
  end

  def part2(patterns) do
    patterns
    |> Enum.map(fn pattern -> pattern |> Pattern.find_reflection(1) |> Pattern.score() end)
    |> Enum.sum()
  end
end

patterns = Main.parse_input(IO.read(:stdio, :all))

{μsec, result} = :timer.tc(fn -> Main.part1(patterns) end)
IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
{μsec, result} = :timer.tc(fn -> Main.part2(patterns) end)
IO.puts("Part 2: #{result} (#{μsec / 1000} ms)")
