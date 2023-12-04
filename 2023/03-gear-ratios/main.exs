defmodule Engine do
  defstruct [:width, :height, :points]

  def new(lines) do
    width = String.length(Enum.at(lines, 0))
    height = Enum.count(lines)
    points = Enum.reduce(lines, [], fn line, acc -> acc ++ String.split(line, "", trim: true) end)

    %__MODULE__{width: width, height: height, points: points}
  end

  # return the contents of the point at x, y; returns nil if out of bounds
  defp at(engine, x, y) do
    if x < 0 || x >= engine.width || y < 0 || y >= engine.height do
      nil
    else
      Enum.at(engine.points, y * engine.width + x)
    end
  end

  # given an index, return the x, y coordinates
  defp xy_from_idx(engine, idx) do
    {rem(idx, engine.width), div(idx, engine.width)}
  end

  # return the contents of the neighbors of the point at x, y
  defp neighbors(engine, x, y) do
    [
      at(engine, x - 1, y - 1),
      at(engine, x, y - 1),
      at(engine, x + 1, y - 1),
      at(engine, x - 1, y),
      at(engine, x + 1, y),
      at(engine, x - 1, y + 1),
      at(engine, x, y + 1),
      at(engine, x + 1, y + 1)
    ]
  end

  # return neighbors that are [full] numbers
  # but for the first and last row of neighbors, we need to collapse consecutive numbers to one number
  # there has got to be a less stupid way of doing this
  defp number_neighbors(engine, x, y) do
    neighbors(engine, x, y)
    |> (fn [a, b, c, d, e, f, g, h] ->
        cond do
          is_number(a) and !is_number(b) and is_number(c) -> [a, c]
          is_number(a) -> [a]
          is_number(b) -> [b]
          is_number(c) -> [c]
          true -> []
        end
        ++ (if is_number(d), do: [d], else: [])
        ++ (if is_number(e), do: [e], else: [])
        ++ cond do
          is_number(f) and !is_number(g) and is_number(h) -> [f, h]
          is_number(f) -> [f]
          is_number(g) -> [g]
          is_number(h) -> [h]
          true -> []
        end
      end).()
  end

  defp numeric?(point) do
    is_binary(point) and Integer.parse(point) != :error
  end

  defp symbol?(point) do
    point != "." and !numeric?(point) and !is_number(point)
  end

  defp find_full_number(engine, x, y, number) do
    if numeric?(at(engine, x + 1, y)) do
      new_number = number * 10 + String.to_integer(at(engine, x + 1, y))
      find_full_number(engine, x + 1, y, new_number)
    else
      number
    end
  end

  # find all the numbers in the engine, and update the points with the full numbers
  def update_numbers(engine) do
    new_points = engine.points
    |> Enum.with_index()
    |> Enum.reduce([], fn {point, idx}, acc ->
        {x, y} = xy_from_idx(engine, idx)
        if numeric?(point) do
          # if the last item in acc is a number, use that, otherwise, find the full number
          if is_number(Enum.at(acc, 0)) do
            [Enum.at(acc, 0) | acc]
          else
            [find_full_number(engine, x, y, String.to_integer(point)) | acc]
          end
        else
          [point | acc]
        end
      end)
    |> Enum.reverse()

      %Engine{engine | points: new_points}
  end

  # return the numbers that have a neighbor that is a symbol
  def find_parts(engine) do
    engine.points
    |> Enum.with_index()
    |> Enum.reduce([], fn {point, idx}, acc ->
        {x, y} = xy_from_idx(engine, idx)
        if symbol?(point), do: number_neighbors(engine, x, y) ++ acc, else: acc
      end)
  end

  # return the product of numbers next to gears (*), but only if there are exactly two of them
  def find_gears(engine) do
    # find all the symbols in engine.points and return any numbers they are adjacent to
    engine.points
    |> Enum.with_index()
    |> Enum.reduce([], fn {point, idx}, acc ->
        {x, y} = xy_from_idx(engine, idx)
        if point == "*" do
          adjacent_numbers = number_neighbors(engine, x, y)
          if length(adjacent_numbers) == 2, do: [Enum.product(adjacent_numbers) | acc], else: acc
        else
          acc
        end
      end)
  end
end

defmodule Main do
  def part1(lines) do
    Engine.new(lines)
    |> Engine.update_numbers()
    |> Engine.find_parts()
    |> Enum.sum()
  end

  def part2(lines) do
    Engine.new(lines)
    |> Engine.update_numbers()
    |> Engine.find_gears()
    |> Enum.sum()
  end
end

lines =
  IO.read(:stdio, :all)
  |> String.split("\n", trim: true)

IO.puts("Part 1: #{Main.part1(lines)}")
IO.puts("Part 2: #{Main.part2(lines)}")
