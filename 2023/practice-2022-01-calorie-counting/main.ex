groups = IO.read(:stdio, :all)
  |> String.split("\n\n", trim: true)

sums = groups
    |> Enum.map(fn group ->
        group
          |> String.split("\n", trim: true)
          |> Enum.map(fn n -> String.to_integer(n) end)
          |> Enum.sum() end)

max = Enum.max(sums)

IO.puts("Part 1: #{max}")

top3 = sums
  |> Enum.sort()
  |> Enum.reverse()
  |> Enum.take(3)
  |> Enum.sum()

IO.puts("Part 2: #{top3}")
