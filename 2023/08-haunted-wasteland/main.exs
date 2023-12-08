defmodule Main do
  def find_node(nodes, current_node, end_node_pattern, steps, step_num) do
    step = Enum.at(steps, Integer.mod(step_num, length(steps)))
    {left, right} = Map.get(nodes, current_node)
    target_node = if step == "L", do: left, else: right
    if String.match?(target_node, end_node_pattern) do
      step_num + 1
    else
      find_node(nodes, target_node, end_node_pattern, steps, step_num + 1)
    end
  end

  def parse_input(lines) do
    [steps | nodelist] = lines
    steps = String.split(steps, "", trim: true)
    nodes = Map.new(nodelist, fn line ->
      [node, left, right] = String.split(line, ~r/\W/, trim: true)
      {node, {left, right}}
    end)
    {steps, nodes}
  end

  def part1(lines) do
    {steps, nodes} = parse_input(lines)
    find_node(nodes, "AAA", ~r/^ZZZ$/, steps, 0)
  end

  def part2(lines) do
    {steps, nodes} = parse_input(lines)
    start_nodes = Enum.filter(Map.keys(nodes), &String.match?(&1, ~r/A$/))
    # find cycle length for each start node
    Enum.map(start_nodes, fn node ->
      find_node(nodes, node, ~r/Z$/, steps, 0)
    end)
    # calculate least common multiple of all cycles
    |> Enum.reduce(fn n, acc -> div(acc * n, Integer.gcd(acc, n)) end)
  end
end

lines = IO.read(:stdio, :all) |> String.split("\n", trim: true)

IO.puts("Part 1: #{Main.part1(lines)}")
IO.puts("Part 2: #{Main.part2(lines)}")
