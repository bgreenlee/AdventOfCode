#!/usr/bin/env elixir

defmodule City do
  defstruct blocks: %{}, height: 0, width: 0

  def parse_city(input) do
    lines = String.split(input, "\n", trim: true)
    width = String.length(Enum.at(lines, 0))
    height = Enum.count(lines)

    blocks =
      lines
      |> Enum.with_index()
      |> Enum.map(fn {line, y} ->
        line
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.map(fn {char, x} -> {{x, y}, String.to_integer(char)} end)
      end)
      |> List.flatten()
      |> Map.new()

    {blocks, height, width}
  end

  def heuristic({ax, ay}, {bx, by}) do
    abs(bx - ax) + abs(by - ay) # manhattan distance
  end

  def neighbors(city, {{x, y}, dir, steps}, min_straight, max_straight) do
    case dir do
      :east ->
        [
          {{x + 1, y}, dir, steps + 1},
          (if steps >= min_straight - 1, do: {{x, y + 1}, :south, 0}),
          (if steps >= min_straight - 1, do: {{x, y - 1}, :north, 0}),
        ]
      :west ->
        [
          {{x - 1, y}, dir, steps + 1},
          (if steps >= min_straight - 1, do: {{x, y + 1}, :south, 0}),
          (if steps >= min_straight - 1, do: {{x, y - 1}, :north, 0}),
        ]
      :north ->
        [
          {{x, y - 1}, dir, steps + 1},
          (if steps >= min_straight - 1, do: {{x + 1, y}, :east, 0}),
          (if steps >= min_straight - 1, do: {{x - 1, y}, :west, 0}),
        ]
      :south ->
        [
          {{x, y + 1}, dir, steps + 1},
          (if steps >= min_straight - 1, do: {{x + 1, y}, :east, 0}),
          (if steps >= min_straight - 1, do: {{x - 1, y}, :west, 0}),
        ]
    end
    |> Enum.reject(&is_nil/1)
    |> Enum.reject(fn {{x, y}, _, steps} ->
        x < 0 or x >= city.width or
        y < 0 or y >= city.height or
        steps >= max_straight
      end)
  end

  def reconstruct_path(came_from, current) do
    if Map.has_key?(came_from, current) do
      path = reconstruct_path(came_from, came_from[current])
      [current | path]
    else
      [current]
    end
  end

  def find_path_recurse(city, goal, open_set, came_from, g_score, f_score, min_straight, max_straight) do
    {{_prio, current}, open_set} = PrioQ.extract_min(open_set)
    {cpoint, _cdir, _csteps} = current

    cond do
      cpoint == goal -> reconstruct_path(came_from, current) # found the goal
      true ->
        neighbors = neighbors(city, current, min_straight, max_straight)

        {open_set, came_from, g_score, f_score} =
          Enum.reduce(neighbors, {open_set, came_from, g_score, f_score}, fn neighbor, {open_set, came_from, g_score, f_score} ->
            {npoint, _, _} = neighbor
            tentative_g_score = g_score[current] + city.blocks[npoint]

            if tentative_g_score < Map.get(g_score, neighbor, :infinity) do
              came_from = Map.put(came_from, neighbor, current)
              g_score = Map.put(g_score, neighbor, tentative_g_score)
              f_score = Map.put(f_score, neighbor, tentative_g_score + heuristic(npoint, goal))
              open_set = PrioQ.add_with_priority(open_set, neighbor, f_score[neighbor])
              {open_set, came_from, g_score, f_score}
            else
              {open_set, came_from, g_score, f_score}
            end
          end)
        find_path_recurse(city, goal, open_set, came_from, g_score, f_score, min_straight, max_straight)
    end
  end

  def find_path(city, start, dir, goal, min_straight, max_straight) do
    open_set = PrioQ.new() |> PrioQ.add_with_priority({start, dir, 0}, 0)
    came_from = Map.new()
    g_score = %{{start, dir, 0} => 0}
    f_score = %{{start, dir, 0} => heuristic(start, goal)}

    find_path_recurse(city, goal, open_set, came_from, g_score, f_score, min_straight, max_straight)
  end

  def new(input) do
    {blocks, height, width} = parse_city(input)
    %__MODULE__{blocks: blocks, height: height, width: width}
  end
end

defimpl String.Chars, for: City do
  def to_string(city) do
    Enum.reduce(0..(city.height - 1), "\n", fn y, acc ->
      Enum.reduce(0..(city.width - 1), acc, fn x, acc ->
        acc <> "#{city.blocks[{x, y}]}"
      end)
      |> Kernel.<>("\n")
    end)
  end
end

# PrioQ from https://blog.ftes.de/elixir-dijkstras-algorithm-with-priority-queue-f6022d710877
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


defmodule Main do
  def solve(input, min_straight \\ 0, max_straight \\ 3) do
    city = City.new(input)
    city
    |> City.find_path({0, 0}, :east, {city.width - 1, city.height - 1}, min_straight, max_straight)
    |> List.delete_at(-1) # don't count the start
    |> Enum.map(fn {{x, y}, _, _} -> city.blocks[{x, y}] end)
    |> Enum.sum()
  end
end

input = IO.read(:stdio, :all)

{μsec, result} = :timer.tc(fn -> Main.solve(input, 0, 3) end)
IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
{μsec, result} = :timer.tc(fn -> Main.solve(input, 4, 10) end)
IO.puts("Part 2: #{result} (#{μsec / 1000} ms)")
