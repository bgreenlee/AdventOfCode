defmodule Main do
  # return the list of draws in the form {color: num}
  def parse_game(line) do
    Regex.scan(~r/(\d+) (\w+)/, line)
    |> Enum.map(fn [_whole_match, num, color] ->
      {String.to_atom(color), String.to_integer(num)}
    end)
  end

  def part1(lines) do
    max = %{:red => 12, :green => 13, :blue => 14}

    lines
    |> Enum.with_index()
    |> Enum.reduce(0, fn {line, idx}, acc ->
      draws = parse_game(line)

      if Enum.any?(draws, fn {color, num} -> num > Map.get(max, color) end),
        do: acc, # got a color over max, so skip
        else: idx + 1 + acc # all good, count the game
     end)
  end

  def part2(lines) do
    lines
    |> Enum.reduce(0, fn line, acc ->
      draws = parse_game(line)
      # get the max number of each color
      max =
        Enum.reduce(draws, %{}, fn {color, num}, acc ->
          Map.update(acc, color, num, fn current -> max(current, num) end)
        end)

      power = max[:red] * max[:green] * max[:blue]
      power + acc
    end)
  end
end

lines =
  IO.read(:stdio, :all)
  |> String.split("\n", trim: true)

IO.puts("Part 1: #{Main.part1(lines)}")
IO.puts("Part 2: #{Main.part2(lines)}")
