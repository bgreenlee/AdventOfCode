defmodule Main do
  defp parse_input(input, split_nums \\ true) do
    [time_strs, distance_strs] = input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line -> String.split(line, ~r/\D/, trim: true) end)

    times = if split_nums do
      time_strs |> Enum.map(&String.to_integer/1)
    else
      [time_strs |> Enum.join() |> String.to_integer()]
    end

    distances = if split_nums do
      distance_strs |> Enum.map(&String.to_integer/1)
    else
      [distance_strs |> Enum.join() |> String.to_integer()]
    end

    Enum.zip(times, distances)
  end

  defp solve_races(races) do
    races
    |> Enum.map(fn {time, record} ->
      # original iterative solution
      # Enum.map(1..(time - 1), fn t -> (time - t) * t end) |> Enum.count(fn x -> x > record end)
      # ChatGPT's closed-form solution (https://chat.openai.com/share/d9cb1265-ee46-4e46-bbb8-2ba74361d24b)
      x = :math.sqrt(:math.pow(time, 2) - 4 * record)/2
      trunc(1 - ceil(time / 2 - x) + floor(time / 2 + x))
    end)
    |> Enum.product()
  end

  def part1(input) do
    input
    |> parse_input()
    |> solve_races()
  end

  def part2(input) do
    input
    |> parse_input(false)
    |> solve_races()
  end
end

input = IO.read(:stdio, :all)

IO.puts("Part 1: #{Main.part1(input)}")
IO.puts("Part 2: #{Main.part2(input)}")
