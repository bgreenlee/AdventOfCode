defmodule Main do
  # recursively find the first node matching the end node pattern,
  # returning the number of steps to get there
  def count_steps(nodes, current_node, end_node_pattern, steps, step_num) do
    step = Enum.at(steps, Integer.mod(step_num, length(steps)))
    target_node = nodes[current_node][step]
    if String.match?(target_node, end_node_pattern) do
      step_num + 1
    else
      count_steps(nodes, target_node, end_node_pattern, steps, step_num + 1)
    end
  end

  def parse_input(input) do
    [steps | nodelist] = String.split(input, "\n", trim: true)
    steps = String.split(steps, "", trim: true)
    nodes = Map.new(nodelist, fn line ->
      [node, left, right] = String.split(line, ~r/\W/, trim: true)
      {node, %{"L" => left, "R" => right}}
    end)
    {steps, nodes}
  end

  def part1(steps, nodes) do
    count_steps(nodes, "AAA", ~r/^ZZZ$/, steps, 0)
  end

  def part2(steps, nodes) do
    # get all starting nodes
    Enum.filter(Map.keys(nodes), &String.match?(&1, ~r/A$/))
    # find cycle length for each start node
    |> Enum.map(fn node -> count_steps(nodes, node, ~r/Z$/, steps, 0) end)
    # calculate least common multiple of all cycles
    |> Enum.reduce(fn n, acc -> div(acc * n, Integer.gcd(acc, n)) end)
  end
end

{steps, nodes} = Main.parse_input(IO.read(:stdio, :all))

{µsec, result} = :timer.tc(fn -> Main.part1(steps, nodes) end)
IO.puts("Part 1: #{result} (#{µsec/1000} ms)")
{µsec, result} = :timer.tc(fn -> Main.part2(steps, nodes) end)
IO.puts("Part 2: #{result} (#{µsec/1000} ms)")
