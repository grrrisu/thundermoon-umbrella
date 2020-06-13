defmodule Sim.Realm.Data do
  use Agent

  alias Phoenix.PubSub

  require Logger

  @init_data %{data: nil, sim_running: false}

  def start_link(opts) do
    Agent.start_link(
      fn ->
        Logger.debug("start realm data")

        @init_data
        |> Map.put_new(:pubsub, opts[:pubsub])
        |> Map.put_new(:topic, opts[:topic])
      end,
      name: (opts[:name] && agent_name(opts[:name])) || __MODULE__
    )
  end

  def reset(agent) do
    Agent.update(agent, fn current -> Map.merge(current, @init_data) end)
  end

  def get_data(%{name: name}) do
    agent_name(name) |> get_data()
  end

  def get_data(agent) do
    Agent.get(agent, & &1.data)
  end

  def set_data(%{name: name}, data) do
    agent_name(name) |> set_data(data)
  end

  def set_data(agent, data) do
    Agent.update(agent, fn state ->
      :ok = broadcast(state, {:update, data: data})
      %{state | data: data}
    end)
  end

  def set_running(%{name: name}, value) do
    agent_name(name) |> set_running(value)
  end

  def set_running(agent, value) when is_boolean(value) do
    Agent.update(agent, fn state ->
      :ok = broadcast(state, {:sim, started: value})
      %{state | sim_running: value}
    end)
  end

  def running?(%{name: name}) do
    agent_name(name) |> Data.running?()
  end

  def running?(agent) do
    Agent.get(agent, & &1.sim_running)
  end

  defp agent_name(name) do
    Module.concat(name, "Data")
  end

  defp broadcast(state, payload) do
    PubSub.broadcast(state.pubsub, state.topic, payload)
  end
end
