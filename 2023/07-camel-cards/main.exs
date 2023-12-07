defmodule Main do
  def hand_rank(hand, use_jokers \\ false) do
    # create map of card => count
    initial_card_map = Enum.reduce(hand, %{}, fn card, acc -> Map.update(acc, card, 1, &(&1 + 1)) end)

    # convert map to list sorted by count, then card rank, descending
    initial_card_counts =
      initial_card_map
      |> Map.to_list()
      |> Enum.sort_by(fn {card, count} -> {count, card_rank(card, use_jokers)} end, :desc)

    # if we're using jokers, update the map so the joker is the card with the highest count and rank
    card_counts =
      if use_jokers and Map.has_key?(initial_card_map, "J") do
        high_card =
          initial_card_counts
          |> Enum.find({"A", 5}, fn {card, _count} -> card != "J" end)
          |> elem(0)

        joker_count = Map.get(initial_card_map, "J")

        initial_card_map
        |> Map.update(high_card, 5, &(&1 + joker_count))
        |> Map.delete("J")
        |> Map.to_list()
        |> Enum.sort_by(fn {card, count} -> {count, card_rank(card, use_jokers)} end, :desc)
      else
        initial_card_counts
      end

    counts = card_counts |> Enum.map(fn {_card, count} -> count end)

    cond do
      counts == [5] -> 6
      counts == [4, 1] -> 5
      counts == [3, 2] -> 4
      counts == [3, 1, 1] -> 3
      counts == [2, 2, 1] -> 2
      counts == [2, 1, 1, 1] -> 1
      true -> 0
    end
  end

  def card_rank(card, use_jokers \\ false) do
    cond do
      card == "A" -> 14
      card == "K" -> 13
      card == "Q" -> 12
      card == "J" -> if use_jokers, do: 1, else: 11
      card == "T" -> 10
      true -> String.to_integer(card)
    end
  end

  def solve(lines, use_jokers \\ false) do
    lines
    |> Enum.map(fn line ->
      [hand_str, bid] = line |> String.split(" ")
      hand = String.split(hand_str, "", trim: true)
      {hand, hand_rank(hand, use_jokers), String.to_integer(bid)}
    end)
    |> Enum.sort_by(
      fn {hand, hand_rank, _} ->
        {hand_rank, hand |> Enum.map(&card_rank(&1, use_jokers))}
      end,
      :asc
    )
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {{_hand, _rank, bid}, idx}, acc -> acc + idx * bid end)
  end
end

lines = IO.read(:stdio, :all) |> String.split("\n", trim: true)

IO.puts("Part 1: #{Main.solve(lines)}")
IO.puts("Part 2: #{Main.solve(lines, true)}")
