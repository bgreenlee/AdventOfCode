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
    if PrioQ.size(open_set) == 0 do
      g_score
    else
      {{_prio, current}, open_set} = PrioQ.extract_min(open_set)

      neighbors = neighbors(map, current)

      {open_set, g_score} =
        Enum.reduce(neighbors, {open_set, g_score}, fn neighbor, {open_set, g_score} ->
          tentative_g_score = g_score[current] + 1

          if tentative_g_score < Map.get(g_score, neighbor, :infinity) do
            g_score = Map.put(g_score, neighbor, tentative_g_score)
            open_set = PrioQ.add_with_priority(open_set, neighbor, tentative_g_score)
            {open_set, g_score}
          else
            {open_set, g_score}
          end
        end)
      find_distances(map, open_set, g_score)
    end
  end

  def display(map) do
    {width, height} = Enum.reduce(map, {0, 0}, fn {{x, y}, _}, {width, height} ->
      {max(x, width), max(y, height)}
    end)
    Enum.reduce(0..(height - 1), "", fn y, acc ->
      Enum.reduce(0..(width - 1), acc, fn x, acc ->
        acc <> "#{map[{x, y}]}"
      end)
      |> Kernel.<>("\n")
    end)
  end

  def part1(input, step_target) do
    map = parse_map(input)
    start = Enum.find_value(map, fn {k, v} -> v == "S" && k end)

    find_distances(map, PrioQ.new([{0, start}]), %{start => 0})
    |> Enum.count(fn {_, v} -> v <= step_target and rem(v, 2) == rem(step_target, 2) end)
  end

  # Much help from https://github.com/villuna/aoc23/wiki/A-Geometric-solution-to-advent-of-code-2023,-day-21
  def part2(input, step_target) do
    map = parse_map(input)
    width = Enum.reduce(map, 0, fn {{x, _}, _}, width -> max(x, width) end) + 1
    half_width = div(width, 2)

    start = Enum.find_value(map, fn {k, v} -> v == "S" && k end)

    map = find_distances(map, PrioQ.new([{0, start}]), %{start => 0})

    even_full = Enum.count(map, fn {_, v} -> rem(v, 2) == 0 end)
    odd_full = Enum.count(map, fn {_, v} -> rem(v, 2) == 1 end)
    even_corners = Enum.count(map, fn {_, v} -> v > half_width and rem(v, 2) == 0 end)
    odd_corners = Enum.count(map, fn {_, v} -> v > half_width and rem(v, 2) == 1 end)

    n = div(step_target - half_width, width)
    (n + 1) * (n + 1) * odd_full + n * n * even_full - (n + 1) * odd_corners + n * even_corners
  end
end

# Priority queue from https://blog.ftes.de/elixir-dijkstras-algorithm-with-priority-queue-f6022d710877
defmodule PrioQ do
  defstruct [:set]

  def new(), do: %__MODULE__{set: :gb_sets.empty()}
  def new([]), do: new()
  def new([{_prio, _elem} | _] = list), do: %__MODULE__{set: :gb_sets.from_list(list)}

  def add_with_priority(%__MODULE__{} = q, elem, prio) do
    %{q | set: :gb_sets.add({prio, elem}, q.set)}
  end

  def size(%__MODULE__{} = q) do
    :gb_sets.size(q.set)
  end

  def extract_min(%__MODULE__{} = q) do
    case :gb_sets.size(q.set) do
      0 -> :empty
      _else ->
        {{prio, elem}, set} = :gb_sets.take_smallest(q.set)
        {{prio, elem}, %{q | set: set}}
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%PrioQ{} = q, opts) do
      concat(["#PrioQ.new(", to_doc(:gb_sets.to_list(q.set), opts), ")"])
    end
  end
end

input = IO.read(:stdio, :all)

{μsec, result} = :timer.tc(fn -> Main.part1(input, 64) end)
IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
{μsec, result} = :timer.tc(fn -> Main.part2(input, 26501365) end)
IO.puts("Part 2: #{result} (#{μsec / 1000} ms)")
