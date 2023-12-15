#!/usr/bin/env elixir

defmodule Main do
  def hash(str) do
    str
    |> String.to_charlist()
    |> Enum.reduce(0, fn char, acc -> rem((acc + char) * 17, 256) end)
  end

  def part1(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(fn cmd -> hash(cmd) end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.reduce(%{}, fn cmd, acc ->
      case String.split(cmd, ["-", "="], trim: true) do
        [label, n] ->
          Map.update(acc, hash(label), [{label, n}], fn list ->
            if List.keymember?(list, label, 0) do
              List.keyreplace(list, label, 0, {label, n})
            else
              list ++ [{label, n}]
            end
          end)
        [label] ->
          Map.update(acc, hash(label), [], fn list ->
            Enum.reject(list, fn {l, _} -> l == label end)
          end)
      end
    end)
    |> Map.to_list()
    |> Enum.map(fn {box, list} ->
        list
        |> Enum.with_index()
        |> Enum.map(fn {{_label, len}, i} -> Enum.product([box + 1, i + 1, String.to_integer(len)]) end)
       end)
    |> List.flatten()
    |> Enum.sum()
  end

end

input = IO.read(:stdio, :all)

{μsec, result} = :timer.tc(fn -> Main.part1(input) end)
IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
{μsec, result} = :timer.tc(fn -> Main.part2(input) end)
IO.puts("Part 2: #{result} (#{μsec / 1000} ms)")
