defmodule Sim.Realm.Data do
  use Agent

  @init_data %{data: nil, sim_running: false}

  def start_link(opts \\ []) do
    Agent.start_link(fn -> @init_data end, name: opts[:name] || __MODULE__)
  end

  def reset() do
    Agent.update(__MODULE__, fn _ -> @init_data end)
  end

  def get_data() do
    Agent.get(__MODULE__, & &1.data)
  end

  def set_data(data) do
    Agent.update(__MODULE__, &Map.put(&1, :data, data))
  end

  def set_running(value) when is_boolean(value) do
    Agent.update(__MODULE__, &Map.put(&1, :sim_running, value))
  end

  def running?() do
    Agent.get(__MODULE__, & &1.sim_running)
  end
end
