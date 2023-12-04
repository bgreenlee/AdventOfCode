defmodule Main do
  # parse a card line, returning a list of MapSets, [winning_nums, my_nums]
  defp parse_card(line) do
    String.split(line, ~r/Card\s+\d+:|\|/, trim: true)
    |> Enum.map(fn num_str ->
        num_str
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> MapSet.new()
      end)
  end

  defp collect_cards(card_map, remaining, total) do
    if length(remaining) == 0 do
      total
    else
      [head | tail] = remaining
      num_cards = map_size(card_map)
      num_new_cards = card_map[head]
      new_cards = if num_new_cards == 0 or head == num_cards-1, do: [], else: Enum.to_list(head+1..min(head+num_new_cards, num_cards-1))
      collect_cards(card_map, new_cards ++ tail, total + length(new_cards))
    end
  end

  def part1(lines) do
    lines
    |> Enum.reduce(0, fn line, acc ->
      [winning_nums, my_nums] = parse_card(line)
      matching_nums = MapSet.to_list(MapSet.intersection(winning_nums, my_nums))
      if length(matching_nums) > 0, do: acc + Integer.pow(2, length(matching_nums) - 1), else: acc
    end)
  end

  def part2(lines) do
    card_map = lines
    |> Enum.map(&parse_card/1)
    |> Enum.with_index()
    |> Map.new(fn {[winning_nums, my_nums], idx} ->
      {idx, MapSet.size(MapSet.intersection(winning_nums, my_nums))}
    end)
    num_cards = map_size(card_map)
    collect_cards(card_map, Enum.to_list(0..num_cards-1), num_cards)
  end
end

lines =
  IO.read(:stdio, :all)
  |> String.split("\n", trim: true)

IO.puts("Part 1: #{Main.part1(lines)}")
IO.puts("Part 2: #{Main.part2(lines)}")
