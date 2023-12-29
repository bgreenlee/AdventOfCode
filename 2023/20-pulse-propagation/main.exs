#!/usr/bin/env elixir

defmodule Pulse do
  defstruct state: :low, source: nil, dest: nil
end

defimpl String.Chars, for: Pulse do
  def to_string(pulse) do
    "#{pulse.source} -#{pulse.state}-> #{pulse.dest}"
  end
end

defmodule Mod do
  defstruct name: "", type: "", value: :off, inputs: %{}, outputs: []

  # send a pulse to this module
  # returns the new module state and a list of pulses to send
  def send_pulse(mod, pulse) do
    Process.put(pulse.state, Process.get(pulse.state, 0) + 1) # low/high counter for part 1
    # part 2
    # maybe lazy to use Process, but it's cleaner
    watch_nodes = Process.get(:watch_nodes)
    if watch_nodes do
      if Map.has_key?(watch_nodes, pulse.source) and pulse.state == :high do
        watch_nodes = Map.put(watch_nodes, pulse.source, Process.get(:count))
        Process.put(:watch_nodes, watch_nodes)
      end
    end

    case mod.type do
      "b" -> {mod, Enum.map(mod.outputs, fn output -> %Pulse{state: pulse.state, source: mod.name, dest: output} end)}
      "%" ->
        case pulse.state do
          :low -> {
            %__MODULE__{mod | value: mod.value == :off && :on || :off},
            Enum.map(mod.outputs, fn output -> %Pulse{state: mod.value == :off && :high || :low, source: mod.name, dest: output} end)
          }
          _ -> {mod, []}
        end
      "&" ->
        inputs = Map.put(mod.inputs, pulse.source, pulse.state)
        # if all inputs are high, send a low pulse, otherwise send a high pulse
        pulse_state = if Enum.all?(inputs, fn {_, state} -> state == :high end) do :low else :high end
        {
          %__MODULE__{mod | inputs: inputs, value: pulse_state},
          Enum.map(mod.outputs, fn output -> %Pulse{state: pulse_state, source: mod.name, dest: output} end)
        }
      _ -> {mod, []}
      end
  end

  def new(line) do
    [module, outputs] = String.split(line, " -> ", trim: true)
    outputs = String.split(outputs, ", ", trim: true)
    type = String.first(module)
    name = String.slice(module, 1..-1//1)
    %__MODULE__{name: name, type: type, outputs: outputs}
  end
end

defmodule Main do

  def process_pulses(modules, pulses) do
    if pulses == [] do
      modules
    else
      [next_pulse | rest_pulses] = pulses
      mod = Map.get(modules, next_pulse.dest, %Mod{name: next_pulse.dest})
      {mod, new_pulses} = Mod.send_pulse(mod, next_pulse)
      modules = Map.put(modules, mod.name, mod)
      process_pulses(modules, rest_pulses ++ new_pulses)
    end
  end

  def push_button(modules, times) do
    if times == 0 do
      modules
    else
      modules = process_pulses(modules, [%Pulse{state: :low, source: "button", dest: "roadcaster"}])
      push_button(modules, times - 1)
    end
  end

  def parse_modules(input) do
    modules = input
    |> String.split("\n")
    |> Enum.map(fn line -> Mod.new(line) end)
    |> Enum.map(fn mod -> {mod.name, mod} end)
    |> Map.new()

    # update conjunction modules with their inputs
    con_mods = modules
    |> Enum.filter(fn {_, mod} -> mod.type == "&" end)
    |> Enum.map(fn {_, mod} ->
        inputs = modules |> Enum.filter(fn {_, m} -> m.outputs |> Enum.member?(mod.name) end)
        {mod.name, Map.put(mod, :inputs, inputs |> Enum.map(fn {_, m} -> {m.name, :low} end) |> Map.new())}
        end)
    |> Map.new()

    modules |> Map.merge(con_mods)
  end

  def part1(input) do
    input
    |> parse_modules()
    |> push_button(1000)

    Process.get(:low) * Process.get(:high)
  end

  def find_cycles(modules, count \\ 1) do
    Process.put(:count, count)
    modules = push_button(modules, 1)
    watch_nodes = Process.get(:watch_nodes)
    if Enum.all?(watch_nodes, fn {_, count} -> count > 0 end) do
        Map.values(watch_nodes) |> Enum.reduce(fn n, acc -> div(acc * n, Integer.gcd(acc, n)) end) # LCM
    else
      find_cycles(modules, count + 1)
    end
  end

  def part2(input) do
    modules = input
    |> parse_modules()

    watch_nodes = modules
    |> Enum.filter(fn {_, mod} -> mod.outputs |> Enum.member?("rx") end)
    |> Enum.flat_map(fn {mod, _} -> modules[mod].inputs |> Map.keys() end)
    |> Enum.map(fn mod -> {mod, 0} end)
    |> Map.new()

    Process.put(:watch_nodes, watch_nodes)

    find_cycles(modules)
  end
end

input = IO.read(:stdio, :all)

{μsec, result} = :timer.tc(fn -> Main.part1(input) end)
IO.puts("Part 1: #{result} (#{μsec / 1000} ms)")
{μsec, result} = :timer.tc(fn -> Main.part2(input) end)
IO.puts("Part 2: #{result} (#{μsec / 1000} ms)")
