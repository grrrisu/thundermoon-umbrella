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

  # use a function that does not raise an exception, but returns {:ok, result} {:error, reason} tuples
  def get_data(agent, get_func) when is_function(get_func) do
    Agent.get(agent, &get_func.(&1.data))
  end

  def get_data(agent) do
    Agent.get(agent, & &1.data)
  end

  # use a function that does not raise an exception, but returns {:ok, result} {:error, reason} tuples
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

  # use a function that does not raise an exception, but returns {:ok, result} {:error, reason} tuples
  def update(agent, update_func) when is_function(update_func) do
    Agent.update(agent, fn state ->
      %{state | data: state.data |> update_func.()}
    end)
  end
end
