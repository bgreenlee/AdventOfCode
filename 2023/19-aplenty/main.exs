#!/usr/bin/env elixir

defmodule Main do
  def parse_workflows(workflows) do
    workflows
    |> String.split("\n")
    |> Enum.map(fn line ->
      [_, name, code] = Regex.run(~r/^(\w+)\{(.*?)\}/, line)
      conds = String.split(code, ",")
      else_cond = Enum.at(conds, -1)
      conds = Enum.drop(conds, -1)
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
      [x, m, a, s] = line
      |> String.split(~r/\D+/, trim: true)
      |> Enum.map(&String.to_integer/1)
      %{"x" => x, "m" => m, "a" => a, "s" => s}
    end)
  end

  def process_part(workflows, cur_wf, part) do
    {conds, else_cond} = workflows[cur_wf]
    next_wf = Enum.find_value(conds, else_cond, fn {var, op, val, workflow} ->
      cond do
        op == ">" and part[var] > val -> workflow
        op == "<" and part[var] < val -> workflow
        true -> nil
      end
    end)
    if Enum.member?(["A", "R"], next_wf), do: next_wf, else: process_part(workflows, next_wf, part)
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

  def part2(input) do
    [workflows, _parts] = String.split(input, "\n\n")
    workflows = parse_workflows(workflows)
    # find all conds that end in "A"
    options = workflows
    |> Enum.flat_map(fn {_name, {conds, _}} -> conds end)
    |> Enum.filter(fn {_, _, _, workflow} -> workflow == "A" end)
    |> Enum.group_by(fn {var, op, _val, _} -> {var, op} end)
    |> Enum.map(fn {{var, op}, conds} ->
      vals = Enum.map(conds, fn {_, _, val, _} -> val end)
      cond do
        op == ">" -> {var, 4000 - Enum.min(vals)}
        op == "<" -> {var, Enum.max(vals) - 1}
      end
    end)
    |> Enum.group_by(fn {var, _} -> var end)
    |> Enum.map(fn {var, var_vals} -> {var, Enum.sum(Enum.map(var_vals, fn {_, val} -> val end))} end)
    |> Map.new()

    Map.get(options, "x", 4000) * Map.get(options, "m", 4000) * Map.get(options, "a", 4000) * Map.get(options, "s", 4000)
    |> IO.inspect()

    # now get all the else clause options
    # else_clause_options = workflows
    # |> Enum.filter(fn {_name, {_, else_cond}} -> else_cond == "A" end)
    # |> Enum.flat_map(fn {_name, {conds, _else_cond}} -> conds end)
    # |> Enum.group_by(fn {var, op, _val, _} -> {var, op} end)
    # |> Enum.map(fn {{_var, op}, conds} ->
    #   vals = Enum.map(conds, fn {_, _, val, _} -> val end)
    #   cond do
    #     op == ">" -> Enum.max(vals)
    #     op == "<" -> 4000 - Enum.min(vals)
    #   end
    # end)
    # |> Enum.product()
    # |> IO.inspect()

    # main_clause_options * else_clause_options
  end
end

input = IO.read(:stdio, :all)

{μsec, result} = :timer.tc(fn -> Main.part1(input) end)
IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
{μsec, result} = :timer.tc(fn -> Main.part2(input) end)
IO.puts("Part 2: #{result} (#{μsec / 1000} ms)")
