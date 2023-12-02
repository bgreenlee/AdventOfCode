defmodule Main do
  # parse the line into a tuple of game number and list of draws
  def parse_game(line) do
    [game_num, draws] = line |> String.split(~r/Game |:/, trim: true)
    game_num = String.to_integer(game_num)
    # convert draws into a list of maps (e.g. [%{red: 1, green: 2, blue: 3}, ...])
    draws =
      String.split(draws, ";", trim: true)
      |> Enum.map(fn draw ->
           String.split(draw, ",", trim: true)
           |> Enum.map(fn color ->
                [num, color] = String.split(color, " ", trim: true)
                {String.to_atom(color), String.to_integer(num)}
              end)
           |> Enum.into(%{red: 0, green: 0, blue: 0})
         end)

    {game_num, draws}
  end

  def part1(lines) do
    max = %{:red => 12, :green => 13, :blue => 14}

    lines
    |> Enum.map(&parse_game/1)
    |> Enum.reduce(0, fn {num, draws}, acc ->
        if Enum.any?(draws, fn draw ->
          Enum.any?(draw, fn {color, num} -> num > Map.get(max, color) end)
        end), do: acc, else: num + acc
    end)
  end

  def part2(lines) do
    lines
    |> Enum.map(&parse_game/1)
    |> Enum.reduce(0, fn {_, draws}, acc ->
      # get the max number of each color
      max =
        Enum.reduce(draws, %{}, fn draw, acc ->
          Enum.reduce(draw, acc, fn {color, num}, acc ->
            Map.update(acc, color, num, fn current -> max(current, num) end)
          end)
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
