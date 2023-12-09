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

  # factorial
  def fact(n) do
    if n == 0, do: 1, else: Enum.reduce(1..n, 1, &*/2)
  end

  # given a list of differences and a sequence number n, calculate the value of the sequence at n
  # see https://mathworld.wolfram.com/FiniteDifference.html
  def sequence_at(diffs, n) do
    diffs
    |> Enum.with_index()
    |> Enum.map(fn {d, i} ->
      if i == 0,
        do: d,
        else: trunc(1 / fact(i) * d * Enum.product(Enum.map(0..(i - 1), fn x -> n - 1 - x end)))
    end)
    |> Enum.sum()
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

  # recursively generate all differences of the sequence until the differences are constant
  def all_differences(sequence) do
    diffs = differences(sequence)
    if length(Enum.uniq(diffs)) == 1 do
      [diffs]
    else
      [diffs] ++ all_differences(diffs)
    end
  end

  def part1(sequences) do
    sequences
    |> Enum.map(fn sequence ->
      sequence
      # |> IO.inspect()
      |> all_differences()
      # |> IO.inspect()
      |> then(fn d -> [sequence | d] end) # prepend the original sequence
      |> Enum.map(fn diffs -> Enum.at(diffs, -1) end)
      # |> IO.inspect()
      |> Enum.sum()
      # |> IO.inspect()
    end)
    |> Enum.sum()
  end

  def part1x(sequences) do
    sequences
    |> Enum.map(fn sequence ->
      n = length(sequence) + 1
      sequence
      |> IO.inspect()
      |> all_differences()
      |> IO.inspect()
      |> Enum.map(fn diffs -> hd(diffs) end)
      |> then(fn d -> [ hd(sequence) | d] end) # prepend the first element of the sequence
      |> IO.inspect()
      |> sequence_at(n)
      |> IO.inspect()
    end)
    |> Enum.sum()
  end
end

sequences = Main.parse_input(IO.read(:stdio, :all))

{μsec, result} = :timer.tc(fn -> Main.part1(sequences) end)
IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
# {µsec, result} = :timer.tc(fn -> Main.part2(steps, nodes) end)
# IO.puts("Part 2: #{result} (#{µsec/1000} ms)")
