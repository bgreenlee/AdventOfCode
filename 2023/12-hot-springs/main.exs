#!/usr/bin/env elixir

defmodule Main do
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [springs_str, groups_str] = String.split(line, " ", trim: true)
      springs = String.split(springs_str, "", trim: true)
      groups = String.split(groups_str, ",", trim: true)
      |> Enum.map(&String.to_integer/1)
      {springs, groups}
    end)
  end

  def generate_arrangements(springs) do
    # get the locations of all the unknowns in the springs list
    unknowns = Enum.with_index(springs)
      |> Enum.filter(fn {c, _} -> c == "?" end)
      |> Enum.map(fn {_, i} -> i end)
    num_unknowns = length(unknowns)
    replacements = Enum.map(0..(Integer.pow(2, num_unknowns) - 1), fn i ->
      i
      |> Integer.to_string(2)
      |> String.pad_leading(num_unknowns, "0")
      |> String.split("", trim: true)
      |> Enum.map(fn c -> if c == "0", do: ".", else: "#" end)
    end)

    # replace the corresponding ? in strings with the values in the replacements
    Enum.map(replacements, fn replacement ->
      Enum.zip(replacement, unknowns)
      |> Enum.reduce(springs, fn {c, i}, springs ->
        List.replace_at(springs, i, c)
      end)
    end)
  end

  def part1(rows) do
    rows
    |> Enum.map(fn {springs, groups} ->
      groups_regex = "^\\.*"
      <> (Enum.map(groups, fn group -> "\#{#{group}}" end) |> Enum.join("\\.+"))
      <> "\\.*$"
      |> Regex.compile!()
      generate_arrangements(springs)
      |> Enum.count(fn arrangement -> Regex.match?(groups_regex, Enum.join(arrangement)) end)
    end)
    |> Enum.sum()
  end

  def part2(rows) do
    rows
    |> Enum.map(fn {springs, groups} ->
      groups_regex = "^\\.*"
      <> (Enum.map(groups, fn group -> "\#{#{group}}" end) |> Enum.join("\\.+"))
      <> "\\.*$"
      |> Regex.compile!()
      a1 = generate_arrangements(springs)
      |> Enum.count(fn arrangement -> Regex.match?(groups_regex, Enum.join(arrangement)) end)
      bef = ["?" | springs]
      aft = springs ++ ["?"]
      a2 = case {hd(springs), Enum.at(springs, -1)} do
            {".", "."} -> generate_arrangements(bef) # *
            {".", "?"} -> generate_arrangements(aft)
            {".", "#"} -> generate_arrangements(aft)
            {"?", "."} -> generate_arrangements(bef) # *
            {"?", "?"} -> generate_arrangements(aft) # *
            {"?", "#"} -> generate_arrangements(aft) # *
            {"#", "."} -> generate_arrangements(bef)
            {"#", "?"} -> generate_arrangements(aft)
            {"#", "#"} -> generate_arrangements(aft)
          end
          |> Enum.count(fn arrangement -> Regex.match?(groups_regex, Enum.join(arrangement)) end)
      a1 * Integer.pow(a2, 4)
    end)
    |> Enum.sum()
  end
end

rows = Main.parse_input(IO.read(:stdio, :all))

# {μsec, result} = :timer.tc(fn -> Main.part1(rows) end)
# IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
{μsec, result} = :timer.tc(fn -> Main.part2(rows) end)
IO.puts("Part 2: #{result} (#{μsec / 1000} ms)")
