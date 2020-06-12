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
      name: opts[:name] || __MODULE__
    )
  end

  def reset() do
    Agent.update(__MODULE__, fn current -> Map.merge(current, @init_data) end)
  end

  def get_data() do
    Agent.get(__MODULE__, & &1.data)
  end

  def set_data(data) do
    Agent.update(__MODULE__, fn state ->
      :ok = broadcast(state, {:update, data: data})
      %{state | data: data}
    end)
  end

  def set_running(value) when is_boolean(value) do
    Agent.update(__MODULE__, fn state ->
      :ok = broadcast(state, {:sim, started: value})
      %{state | sim_running: value}
    end)
  end

  def running?() do
    Agent.get(__MODULE__, & &1.sim_running)
  end

  defp broadcast(state, payload) do
    PubSub.broadcast(state.pubsub, state.topic, payload)
  end
end
