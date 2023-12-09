defmodule Main do
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(" ")
      |> Enum.map(fn x -> String.to_integer(x) end)
    end)
  end

  # return a list of differences between the elements of the sequence
  def differences(sequence) do
    sequence
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a,b] -> b - a end)
  end

  def next_in_sequence(sequence) do
    if length(Enum.uniq(sequence)) == 1 do
      hd(sequence)
    else
      Enum.at(sequence, -1) + next_in_sequence(differences(sequence))
    end
  end

  def prev_in_sequence(sequence) do
    if length(Enum.uniq(sequence)) == 1 do
      hd(sequence)
    else
      hd(sequence) - prev_in_sequence(differences(sequence))
    end
  end

  def part1(sequences) do
    sequences
    |> Enum.map(fn s -> next_in_sequence(s) end)
    |> Enum.sum()
  end

  def part2(sequences) do
    sequences
    |> Enum.map(fn s -> prev_in_sequence(s) end)
    |> Enum.sum()
  end
end

sequences = Main.parse_input(IO.read(:stdio, :all))

{μsec, result} = :timer.tc(fn -> Main.part1(sequences) end)
IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
{µsec, result} = :timer.tc(fn -> Main.part2(sequences) end)
IO.puts("Part 2: #{result} (#{µsec/1000} ms)")
