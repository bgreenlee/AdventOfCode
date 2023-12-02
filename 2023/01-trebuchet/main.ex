defmodule Main do
  def line_to_number(line) do
    line
    # remove non-digits
    |> String.replace(~r/[^\d]/, "")
    # remove all but first and last digit
    |> String.replace(~r/(^\d).*?(\d$)/, "\\1\\2")
    # single digits get doubled, ignore no digits
    |> (fn n ->
          case String.length(n) do
            0 -> "0"
            1 -> "#{n}#{n}"
            _ -> n
          end
        end).()
    |> String.to_integer()
  end

  # recursively replace words with numbers until no more words are found
  def words_to_numbers(line) do
    number_regex = ~r/^(one|two|three|four|five|six|seven|eight|nine)/
    word_map = %{"one" => "1", "two" => "2", "three" => "3", "four" => "4", "five" => "5", "six" => "6", "seven" => "7", "eight" => "8", "nine" => "9"}
    line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, idx} ->
          rest_of_line = String.slice(line, idx..-1)
          if String.match?(rest_of_line, number_regex) do
            String.replace(rest_of_line, number_regex, fn word -> word_map[word] end)
          else
            char
          end
        end)
      |> Enum.join()
  end

  def part1(lines) do
    lines
    |> Enum.map(&line_to_number/1)
    |> Enum.sum()
  end

  def part2(lines) do
    lines
    |> Enum.map(&words_to_numbers/1)
    |> Enum.map(&line_to_number/1)
    |> Enum.sum()
  end
end

lines =
  IO.read(:stdio, :all)
  |> String.split("\n", trim: true)

IO.puts("Part 1: #{Main.part1(lines)}")
IO.puts("Part 2: #{Main.part2(lines)}")
