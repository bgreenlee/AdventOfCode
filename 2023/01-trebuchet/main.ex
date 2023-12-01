defmodule Util do
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
    new_line =
      line
      |> String.replace(~r/(one|two|three|four|five|six|seven|eight|nine)/, fn word ->
        # leave the first and last letters because, annoyingly, "oneight" should be "18"
        case word do
          "one" -> "o1e"
          "two" -> "t2o"
          "three" -> "t3e"
          "four" -> "f4r"
          "five" -> "f5e"
          "six" -> "s6x"
          "seven" -> "s7n"
          "eight" -> "e8t"
          "nine" -> "n9e"
        end
      end)

    if new_line == line do
      new_line
    else
      words_to_numbers(new_line)
    end
  end
end

lines =
  IO.read(:stdio, :all)
  |> String.split("\n", trim: true)

sum =
  lines
  |> Enum.map(fn line -> Util.line_to_number(line) end)
  |> Enum.sum()

IO.puts("Part 1: #{sum}")

sum =
  lines
  |> Enum.map(fn line ->
    line
    |> Util.words_to_numbers()
    |> Util.line_to_number()
  end)
  |> Enum.sum()

IO.puts("Part 2: #{sum}")
