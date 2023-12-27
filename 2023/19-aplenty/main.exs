#!/usr/bin/env elixir

defmodule Main do
  def parse_workflows(workflows) do
    workflows
    |> String.split("\n")
    |> Enum.map(fn line ->
      [_, name, code] = Regex.run(~r/^(\w+)\{(.*?)\}/, line)
      conds = String.split(code, ",")
      else_cond = Enum.at(conds, -1)

      conds =
        Enum.drop(conds, -1)
        |> Enum.map(fn cond ->
          [_, var, op, val, workflow] = Regex.run(~r/(\w+)([<>])(\d+):(\w+)/, cond)
          {var, op, String.to_integer(val), workflow}
        end)

      {name, {conds, else_cond}}
    end)
    |> Map.new()
  end

  def parse_parts(parts) do
    parts
    |> String.split("\n")
    |> Enum.map(fn line ->
      [x, m, a, s] =
        line
        |> String.split(~r/\D+/, trim: true)
        |> Enum.map(&String.to_integer/1)

      %{"x" => x, "m" => m, "a" => a, "s" => s}
    end)
  end

  def process_part(workflows, cur_wf, part) do
    {conds, else_cond} = workflows[cur_wf]

    next_wf =
      Enum.find_value(conds, else_cond, fn {var, op, val, workflow} ->
        cond do
          op == ">" and part[var] > val -> workflow
          op == "<" and part[var] < val -> workflow
          true -> nil
        end
      end)

    if Enum.member?(["A", "R"], next_wf),
      do: next_wf,
      else: process_part(workflows, next_wf, part)
  end

  def part1(input) do
    [workflows, parts] = String.split(input, "\n\n")
    workflows = parse_workflows(workflows)

    parse_parts(parts)
    |> Enum.map(fn part -> {part, process_part(workflows, "in", part)} end)
    |> Enum.filter(fn {_, res} -> res == "A" end)
    |> Enum.map(fn {part, _} -> part["x"] + part["m"] + part["a"] + part["s"] end)
    |> Enum.sum()
  end

  # build a binary tree from the workflows
  def build_tree(workflows, wf_or_cond) do
    # IO.inspect(wf_or_cond)
    if wf_or_cond == "A" or wf_or_cond == "R" do
      %{:value => wf_or_cond, true => nil, false => nil}
    else
      {conds, else_cond} =
        case wf_or_cond do
          {conds, else_cond} -> {conds, else_cond}
          wf -> workflows[wf]
        end

      [{var, op, val, true_wf} | conds] = conds

      %{
        :value => {var, op, val},
        true => build_tree(workflows, true_wf),
        false => build_tree(workflows, if(conds == [], do: else_cond, else: {conds, else_cond}))
      }
    end
  end

  # given the above binary tree, find all paths that lead to "A"
  def find_paths(tree) do
    case tree do
      %{:value => "A", true => nil, false => nil} ->
        [[]]

      %{:value => "R", true => nil, false => nil} ->
        []

      %{:value => {var, op, val}, true => true_tree, false => false_tree} ->
        true_paths = find_paths(true_tree)
        false_paths = find_paths(false_tree)
        {false_op, false_val} = if op == "<", do: {">", val - 1}, else: {"<", val + 1}

        Enum.map(true_paths, fn path -> [{var, op, val} | path] end) ++
          Enum.map(false_paths, fn path -> [{var, false_op, false_val} | path] end)
    end
  end

  # given the set of paths that lead to "A", and a set of ranges for each variable (x, m, a, s)
  # filter and subdivide the ranges to only those values that are valid for each path
  def filter_ranges(paths, ranges) do
    paths
    |> Enum.map(fn path ->
      path
      |> Enum.reduce(ranges, fn {var, op, val}, ranges ->
        new_ranges = ranges[var]
        |> Enum.map(fn {min, max} ->
          cond do
            op == "<" and min >= val -> nil
            op == "<" and max < val -> {min, max}
            op == "<" and min < val and max >= val -> {min, val - 1}
            op == ">" and max <= val -> nil
            op == ">" and min > val -> {min, max}
            op == ">" and min <= val and max > val -> {val + 1, max}
            true -> {min, max}
          end
        end)
        |> Enum.reject(&is_nil/1)

        Map.put(ranges, var, new_ranges)
      end)
    end)
  end

  # given the output of filter_ranges, calculate the total combinations
  # for each variable, multiply the number of valid parts for each path
  # then sum up all the paths
  def calculate_combinations(path_ranges) do
    path_ranges
    |> Enum.map(fn ranges ->
      ranges
      |> Enum.map(fn {_var, ranges} -> ranges end)
      |> Enum.map(fn ranges ->
        Enum.reduce(ranges, 0, fn {min, max}, acc -> acc + max - min + 1 end)
      end)
      |> Enum.product()
    end)
    |> Enum.sum()
  end

  def part2(input) do
    [workflows, _parts] = String.split(input, "\n\n")

    parse_workflows(workflows)
    |> build_tree("in")
    |> find_paths()
    |> filter_ranges(%{
      "x" => [{1, 4000}],
      "m" => [{1, 4000}],
      "a" => [{1, 4000}],
      "s" => [{1, 4000}]
    })
    |> calculate_combinations()
  end
end

input = IO.read(:stdio, :all)

{μsec, result} = :timer.tc(fn -> Main.part1(input) end)
IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
{μsec, result} = :timer.tc(fn -> Main.part2(input) end)
IO.puts("Part 2: #{result} (#{μsec / 1000} ms)")
