defmodule Sim.Realm.Data do
  use Agent

  require Logger

  def start_link(opts) do
    Agent.start_link(
      fn ->
        Logger.debug("start realm data")
        %{data: nil}
      end,
      name: opts[:name] || __MODULE__
    )
  end

  def reset(agent) do
    Agent.update(agent, fn state -> %{state | data: nil} end)
  end

  def get_data(agent) do
    Agent.get(agent, & &1.data)
  end

  def set_data(agent, set_func) when is_function(set_func) do
    Agent.update(agent, fn state ->
      %{state | data: set_func.()}
    end)
  end

  def set_data(agent, data) do
    Agent.update(agent, fn state ->
      %{state | data: data}
    end)
  end
end
