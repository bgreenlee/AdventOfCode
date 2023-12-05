defmodule Almanac do
  defstruct seeds: [], maps: %{}

  defp parse_input(input) do
    sections = Regex.named_captures(~r/seeds:\s+(?<seeds>.*?$)\n\n(?<maps>.*)/sm, input)

    seeds = sections["seeds"]
      |> String.split(" ", trim: true)
      |> Enum.map(fn n -> String.to_integer(n) end)

    maps = sections["maps"]
      |> (&Regex.scan(~r/(?<name>.*?) map:\n(?<values>.*?)(?:\n\n|\z)/sm, &1)).()
      |> Map.new(fn [_, name, value_block] ->
            values = value_block
            |> String.split("\n", trim: true)
            |> Enum.map(fn x ->
                String.split(x, " ", trim: true)
                |> Enum.map(fn n -> String.to_integer(n) end)
              end)
            {name, values}
         end)

      {seeds, maps}
  end

  def new(input) do
    {seeds, maps} = parse_input(input)

    %__MODULE__{seeds: seeds, maps: maps}
  end

  def convert(value, almanac, map_name) do
    new_value = almanac.maps[map_name]
      |> Enum.find_value(fn [dest_start, source_start, length] ->
          if value >= source_start and value < source_start + length, do: dest_start + (value - source_start)
        end)
    new_value || value
  end

  def convert_seed_to_location(almanac, seed) do
    seed
      |> convert(almanac, "seed-to-soil")
      |> convert(almanac, "soil-to-fertilizer")
      |> convert(almanac, "fertilizer-to-water")
      |> convert(almanac, "water-to-light")
      |> convert(almanac, "light-to-temperature")
      |> convert(almanac, "temperature-to-humidity")
      |> convert(almanac, "humidity-to-location")
    end
end

defmodule Main do

  def part1(input) do
    almanac = Almanac.new(input)
    almanac.seeds
      |> Enum.map(fn seed -> Almanac.convert_seed_to_location(almanac, seed) end)
      |> Enum.min()
  end

  def part2(input) do
    almanac = Almanac.new(input)
    almanac.seeds
      |> Enum.chunk_every(2)
      |> Enum.map(fn [seed_start, seed_length] ->
            Enum.reduce(seed_start..seed_start+seed_length-1, :infinity, fn seed, acc ->
              loc = Almanac.convert_seed_to_location(almanac, seed)
              if loc < acc, do: loc, else: acc
            end)
         end)
      |> Enum.min()
  end
end

input = IO.read(:stdio, :all)

IO.puts("Part 1: #{Main.part1(input)}")
IO.puts("Part 2: #{Main.part2(input)}")
