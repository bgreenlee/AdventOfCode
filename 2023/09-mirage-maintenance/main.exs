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
    |> Enum.reduce({}, fn x, acc ->
        if acc == {} do
          {[x], x}
        else
          {diffs, last} = acc
          {[x - last | diffs], x}
        end
      end)
    |> elem(0)
    |> Enum.reverse()
    |> tl() # drop the first element, which is not valid
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
