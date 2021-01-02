defmodule Sim.Realm.Data do
  use Agent

  alias Phoenix.PubSub

  require Logger

  def start_link(opts) do
    Agent.start_link(
      fn ->
        Logger.debug("start realm data")
        %{data: nil, pubsub: opts[:pubsub], topic: opts[:topic]}
      end,
      name: opts[:name]
    )
  end

  def reset(agent) do
    Agent.update(agent, fn state -> %{state | data: nil} end)
  end

  def get_data(agent) do
    Agent.get(agent, & &1.data)
  end

  def set_data(agent, data) do
    Agent.update(agent, fn state ->
      :ok = broadcast(state, {:update, data: data})
      %{state | data: data}
    end)
  end

  defp broadcast(state, payload) do
    PubSub.broadcast(state.pubsub, state.topic, payload)
  end
end
