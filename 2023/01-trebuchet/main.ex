defmodule Main do
  def line_to_number(line, convert_words \\ false) do
    number_regex = ~r/^(one|two|three|four|five|six|seven|eight|nine)/
    word_map = %{"one" => "1", "two" => "2", "three" => "3", "four" => "4", "five" => "5", "six" => "6", "seven" => "7", "eight" => "8", "nine" => "9"}
    line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, idx} ->
          cond do
            String.match?(char, ~r/\d/) -> char
            convert_words -> if match = Regex.run(number_regex, String.slice(line, idx..-1)), do: word_map[List.last(match)]
            true -> ""
          end
        end)
      |> Enum.join()
      |> (fn n -> String.slice(n, 0, 1) <> String.slice(n, -1, 1) end).()
      |> String.to_integer()
  end

  def part1(lines) do
    lines
    |> Enum.map(&line_to_number/1)
    |> Enum.sum()
  end

  def part2(lines) do
    lines
    |> Enum.map(&line_to_number(&1, true))
    |> Enum.sum()
  end
end

lines =
  IO.read(:stdio, :all)
  |> String.split("\n", trim: true)

IO.puts("Part 1: #{Main.part1(lines)}")
IO.puts("Part 2: #{Main.part2(lines)}")
