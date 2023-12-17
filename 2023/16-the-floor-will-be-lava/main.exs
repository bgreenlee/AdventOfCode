#!/usr/bin/env elixir

defmodule Layout do
  defstruct points: %{}, height: 0, width: 0

  def parse_layout(input) do
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
        |> Enum.map(fn {char, x} -> {{x, y}, char} end)
      end)
      |> List.flatten()
      |> Map.new()

    {points, height, width}
  end

  def energize(layout, beams, energized \\ nil, seen \\ nil) do
    energized = energized || MapSet.new(beams |> Enum.map(fn {x, y, _, _} -> {x, y} end))
    seen = seen || MapSet.new(beams)

    {beams, energized, seen} =
      beams
      |> Enum.reduce({[], energized, seen}, fn {x, y, dx, dy}, {beams, energized, seen} ->
        new_beams =
          cond do
            char = layout.points[{x, y}] ->
              case char do
                "|" when dx != 0 ->
                  [
                    if(y < layout.height - 1, do: {x, y + 1, 0, 1}),
                    if(y > 0, do: {x, y - 1, 0, -1})
                  ]
                  |> Enum.reject(&is_nil/1)

                "-" when dy != 0 ->
                  [
                    if(x < layout.width - 1, do: {x + 1, y, 1, 0}),
                    if(x > 0, do: {x - 1, y, -1, 0})
                  ]
                  |> Enum.reject(&is_nil/1)

                "/" ->
                  [{x - dy, y - dx, -dy, -dx}]

                "\\" ->
                  [{x + dy, y + dx, dy, dx}]

                _ ->
                  [{x + dx, y + dy, dx, dy}]
              end

            # probably nil and hence out-of-bounds
            true ->
              []
          end
          |> Enum.reject(fn {x, y, dx, dy} ->
            MapSet.member?(seen, {x, y, dx, dy}) or
              x < 0 or x > layout.width - 1 or y < 0 or y > layout.height - 1
          end)

        energized =
          MapSet.union(
            energized,
            MapSet.new(new_beams |> Enum.map(fn {x, y, _, _} -> {x, y} end))
          )

        seen = MapSet.union(seen, MapSet.new(new_beams))
        {beams ++ new_beams, energized, seen}
      end)

    if beams == [] do
      energized
    else
      energize(layout, beams, energized, seen)
    end
  end

  def new(input) do
    {points, height, width} = parse_layout(input)
    %__MODULE__{points: points, height: height, width: width}
  end
end

defimpl String.Chars, for: Layout do
  def to_string(layout) do
    Enum.reduce(0..(layout.height - 1), "\n", fn y, acc ->
      Enum.reduce(0..(layout.width - 1), acc, fn x, acc ->
        cond do
          char = layout.points[{x, y}] -> acc <> char
          true -> acc <> "."
        end
      end)
      |> Kernel.<>("\n")
    end)
  end
end

defmodule Main do
  def part1(input) do
    input
    |> Layout.new()
    |> Layout.energize([{0, 0, 1, 0}])
    |> MapSet.size()
  end

  def part2(input) do
    layout = Layout.new(input)

    Enum.max([
      0..(layout.width - 1)
      |> Enum.map(fn x ->
        [
          Layout.energize(layout, [{x, 0, 0, 1}]) |> MapSet.size(),
          Layout.energize(layout, [{x, layout.height - 1, 0, -1}]) |> MapSet.size()
        ]
      end)
      |> List.flatten()
      |> Enum.max(),
      0..(layout.height - 1)
      |> Enum.map(fn y ->
        [
          Layout.energize(layout, [{0, y, 1, 0}]) |> MapSet.size(),
          Layout.energize(layout, [{layout.width - 1, y, -1, 0}]) |> MapSet.size()
        ]
      end)
      |> List.flatten()
      |> Enum.max()
    ])
  end
end

input = IO.read(:stdio, :all)

{μsec, result} = :timer.tc(fn -> Main.part1(input) end)
IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
{μsec, result} = :timer.tc(fn -> Main.part2(input) end)
IO.puts("Part 2: #{result} (#{μsec / 1000} ms)")
