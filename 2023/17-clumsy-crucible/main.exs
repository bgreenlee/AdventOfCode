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
    # Manhattan distance
    abs(bx - ax) + abs(by - ay)
  end

  def neighbors(city, {x, y}, dir, steps) do
    case dir do
      :east ->
        [
          {x + 1, y, dir, steps + 1},
          {x, y + 1, :south, 0},
          {x, y - 1, :north, 0}
        ]
      :west ->
        [
          {x - 1, y, dir, steps + 1},
          {x, y + 1, :south, 0},
          {x, y - 1, :north, 0}
        ]
      :north ->
        [
          {x, y - 1, dir, steps + 1},
          {x + 1, y, :east, 0},
          {x - 1, y, :west, 0}
        ]
      :south ->
        [
          {x, y + 1, dir, steps + 1},
          {x + 1, y, :east, 0},
          {x - 1, y, :west, 0}
        ]
    end
    |> Enum.reject(fn {x, y, _, steps} ->
        x < 0 or x >= city.width or
        y < 0 or y >= city.height or
        steps > 2
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

  def find_path_recurse(city, goal, open_set, came_from, g_score, f_score) do
    # the node in open_set having the lowest f_score[] value
    # TODO: implement a min heap or priority queue
    {current, {cdir, csteps}} = Enum.min_by(open_set, fn node -> f_score[node] end)

    cond do
      current == goal -> reconstruct_path(came_from, current) # found the goal
      Enum.empty?(open_set) -> nil # couldn't find the goal
      true ->
        open_set = Map.delete(open_set, current)
        neighbors = neighbors(city, current, cdir, csteps)

        {open_set, came_from, g_score, f_score} =
          Enum.reduce(neighbors, {open_set, came_from, g_score, f_score}, fn neighbor, {open_set, came_from, g_score, f_score} ->
            {nx, ny, ndir, nsteps} = neighbor
            # tentative_g_score is the distance from start to the neighbor through current
            tentative_g_score = g_score[current] + city.blocks[{nx, ny}]

            if tentative_g_score < Map.get(g_score, {nx, ny}, :infinity) do
              # this path to neighbor is better than any previous one. Record it!
              came_from = Map.put(came_from, {nx, ny}, current)
              g_score = Map.put(g_score, {nx, ny}, tentative_g_score)
              f_score = Map.put(f_score, {nx, ny}, tentative_g_score + heuristic({nx, ny}, goal))
              open_set = Map.put(open_set, {nx, ny}, {ndir, nsteps})
              {open_set, came_from, g_score, f_score}
            else
              {open_set, came_from, g_score, f_score}
            end
          end)
        find_path_recurse(city, goal, open_set, came_from, g_score, f_score)
    end

  end
  # use A* to find a path from the top left to the bottom right that minimizes the values of the blocks traversed
  # and does not travel in a straight line more than three blocks at a time
  def find_path(city, {sx, sy} = start, direction, goal) do
    # The set of discovered nodes that may need to be (re-)expanded.
    # Initially, only the start node is known.
    # This is usually implemented as a min-heap or priority queue rather than a hash-set.
    open_set = %{{sx, sy} => {direction, 0}}

    # for node n, came_from[n] is the node immediately preceding it on the cheapest path from start to n currently known
    came_from = Map.new()

    # for node n, g_score[n] is the cost of the cheapest path from start to n currently known
    g_score = %{start => 0}

    # for node n, f_score[n] = g_score[n] + h(n). f_score[n] represents our current best guess as to
    # how cheap a path could be from start to finish if it goes through n.
    f_score = %{start => heuristic(start, goal)}

    find_path_recurse(city, goal, open_set, came_from, g_score, f_score)
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

defmodule Main do
  def part1(input) do
    city = City.new(input)
    city
    |> City.find_path({0, 0}, :east, {city.width - 1, city.height - 1})
    |> IO.inspect()
    |> Enum.map(fn {x, y} -> city.blocks[{x, y}] end)
    |> Enum.sum()
  end
end

input = IO.read(:stdio, :all)

{μsec, result} = :timer.tc(fn -> Main.part1(input) end)
IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
# {μsec, result} = :timer.tc(fn -> Main.part2(input) end)
# IO.puts("Part 2: #{result} (#{μsec / 1000} ms)")
