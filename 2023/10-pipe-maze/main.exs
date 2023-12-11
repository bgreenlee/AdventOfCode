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

  def find_start(map) do
    map
    |> Enum.find(fn {_, v} -> v == "S" end)
    |> elem(0)
  end

  # return the at most two neighbors that connect to this point on the map
  # this assumes that the given point can connect to them
  def find_neighbors(map, {x, y}) do
    v = map[{x, y}]
    [
      (if v in ["|", "J", "L", "S"] and map[{x, y - 1}] in ["|", "7", "F", "S"], do: {x, y - 1}, else: nil),
      (if v in ["-", "F", "L", "S"] and map[{x + 1, y}] in ["-", "7", "J", "S"], do: {x + 1, y}, else: nil),
      (if v in ["|", "7", "F", "S"] and map[{x, y + 1}] in ["|", "L", "J", "S"], do: {x, y + 1}, else: nil),
      (if v in ["-", "J", "7", "S"] and map[{x - 1, y}] in ["-", "F", "L", "S"], do: {x - 1, y}, else: nil)
    ]
    |> Enum.reject(&is_nil/1)
  end

  # traverse the map from the starting point, returning the path
  def find_loop(map, start, current, path) do
    last = Enum.at(path, 1)
    next = find_neighbors(map, current)
    |> Enum.reject(fn p -> p == last end)
    |> hd()

    if next == start, do: path, else: find_loop(map, start, next, [next | path])
  end

  # point-in-polygon algorithm from https://observablehq.com/@hg42/untitled
  def is_inside({x, y}, loop) do
    if {x, y} in loop do # on the loop is not inside
      false
    else
      loop
      |> Enum.chunk_every(2, 1, [hd(loop)])
      |> Enum.reduce(false, fn [{x1, y1}, {x2, y2}], inside ->
        if ((y1 > y) != (y2 > y)) and (x < (x2 - x1) * (y - y1) / (y2 - y1) + x1) do
            !inside
        else
            inside
        end
      end)
    end
  end

  # get furthest point in the loop (half the loop length)
  def part1(map) do
    start = find_start(map)
    loop = find_loop(map, start, start, [start])
    div(length(loop), 2)
  end

  # find how many points are contained within the loop
  def part2(map) do
    start = find_start(map)
    loop = find_loop(map, start, start, [start])
    map
    |> Map.keys()
    |> Enum.count(fn p -> is_inside(p, loop) end)
  end
end

map = Main.parse_map(IO.read(:stdio, :all))

{μsec, result} = :timer.tc(fn -> Main.part1(map) end)
IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
{μsec, result} = :timer.tc(fn -> Main.part2(map) end)
IO.puts("Part 2: #{result} (#{μsec / 1000} ms)")
