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
  def differences(seq) do
    seq
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> b - a end)
  end

  def next_in_seq(seq) do
    head = hd(seq)
    if Enum.all?(seq, fn x -> x == head end) do
      head
    else
      List.last(seq) + next_in_seq(differences(seq))
    end
  end

  def prev_in_seq(seq) do
    head = hd(seq)
    if Enum.all?(seq, fn x -> x == head end) do
      head
    else
      head - prev_in_seq(differences(seq))
    end
  end

  def part1(sequences) do
    sequences
    |> Enum.map(&next_in_seq/1)
    |> Enum.sum()
  end

  def part2(sequences) do
    sequences
    |> Enum.map(&prev_in_seq/1)
    |> Enum.sum()
  end
end

sequences = Main.parse_input(IO.read(:stdio, :all))

{μsec, result} = :timer.tc(fn -> Main.part1(sequences) end)
IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
{μsec, result} = :timer.tc(fn -> Main.part2(sequences) end)
IO.puts("Part 2: #{result} (#{μsec / 1000} ms)")
