defmodule Main do
  # parse the line into a tuple of game number and list of games
  def parse_game(line) do
    [game_num, games] = line |> String.split(~r/Game |:/, trim: true)
    game_num = String.to_integer(game_num)
    # convert games into a list of maps (e.g. [%{red: 1, green: 2, blue: 3}, ...])
    games =
      String.split(games, ";", trim: true)
      |> Enum.map(fn game ->
           String.split(game, ",", trim: true)
           |> Enum.map(fn color ->
                [num, color] = String.split(color, " ", trim: true)
                {String.to_atom(color), String.to_integer(num)}
              end)
           |> Enum.into(%{red: 0, green: 0, blue: 0})
         end)

    {game_num, games}
  end

  def part1(lines) do
    max = %{:red => 12, :green => 13, :blue => 14}

    lines
    |> Enum.map(&parse_game/1)
    |> Enum.reduce(0, fn {num, games}, acc ->
        if Enum.any?(games, fn game ->
          Enum.any?(game, fn {color, num} -> num > Map.get(max, color) end)
        end), do: acc, else: num + acc
    end)
  end

  def part2(lines) do
    lines
    |> Enum.map(&parse_game/1)
    |> Enum.map(fn {_, games} ->
      max =
        Enum.reduce(games, %{}, fn game, acc ->
          Enum.reduce(game, acc, fn {color, num}, acc ->
            Map.update(acc, color, num, fn current -> max(current, num) end)
          end)
        end)

      max[:red] * max[:green] * max[:blue]
    end)
    |> Enum.sum()
  end
end

lines =
  IO.read(:stdio, :all)
  |> String.split("\n", trim: true)

IO.puts("Part 1: #{Main.part1(lines)}")
IO.puts("Part 2: #{Main.part2(lines)}")
