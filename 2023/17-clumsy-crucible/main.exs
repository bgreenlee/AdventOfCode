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

  def neighbors(city, {x, y}) do
    [
      {x + 1, y},
      {x - 1, y},
      {x, y + 1},
      {x, y - 1}
    ]
    |> Enum.reject(fn {x, y} ->
        x < 0 or x >= city.width or
        y < 0 or y >= city.height
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
    current = Enum.min_by(open_set, fn node -> f_score[node] end)

    cond do
      current == goal -> reconstruct_path(came_from, current) # found the goal
      MapSet.size(open_set) == 0 -> nil # couldn't find the goal
      true ->
        open_set = MapSet.delete(open_set, current)
        neighbors = neighbors(city, current)

        {open_set, came_from, g_score, f_score} =
          Enum.reduce(neighbors, {open_set, came_from, g_score, f_score}, fn neighbor, {open_set, came_from, g_score, f_score} ->
            # avoid going straight for more than three blocks
            # straight for three means we can have four in a row, since the fourth one was a turn
            last_four = Enum.take(reconstruct_path(came_from, current), 4)
            {cx, cy} = current
            if length(last_four) == 4 and (
              Enum.all?(last_four, fn {x, _} -> x == cx end) or
              Enum.all?(last_four, fn {_, y} -> y == cy end)
            ) do
                {open_set, came_from, g_score, f_score}
            else
              # tentative_g_score is the distance from start to the neighbor through current
              tentative_g_score = Map.get(g_score, current, :infinity) + city.blocks[neighbor]

              if tentative_g_score < Map.get(g_score, neighbor, :infinity) do
                # this path to neighbor is better than any previous one. Record it!
                came_from = Map.put(came_from, neighbor, current)
                g_score = Map.put(g_score, neighbor, tentative_g_score)
                f_score = Map.put(f_score, neighbor, Map.get(g_score, neighbor, :infinity) + heuristic(neighbor, goal))
                open_set = MapSet.put(open_set, neighbor)
                {open_set, came_from, g_score, f_score}
              else
                {open_set, came_from, g_score, f_score}
              end
            end
          end)
        find_path_recurse(city, goal, open_set, came_from, g_score, f_score)
    end

  end
  # use A* to find a path from the top left to the bottom right that minimizes the values of the blocks traversed
  # and does not travel in a straight line more than three blocks at a time
  def find_path(city, start, goal) do
    # The set of discovered nodes that may need to be (re-)expanded.
    # Initially, only the start node is known.
    # This is usually implemented as a min-heap or priority queue rather than a hash-set.
    open_set = MapSet.new([start])

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
    |> City.find_path({0, 0}, {city.width - 1, city.height - 1})
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
