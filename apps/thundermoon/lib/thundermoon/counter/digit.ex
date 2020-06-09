defmodule Thundermoon.Digit do
  # agent is temporary as it will be restarted by the counter
  use Agent, restart: :temporary

  alias ThundermoonWeb.PubSub

  def start(counter, key, value \\ 0) do
    Agent.start(fn ->
      broadcast(key, value)
      %{counter: counter, key: key, value: value}
    end)
  end

  def get(pid) do
    Agent.get(pid, & &1.value)
  end

  def inc(pid) do
    Agent.update(pid, fn state ->
      update(state, fn -> compute_inc(state) end)
    end)
  end

  def dec(pid) do
    Agent.update(pid, fn state ->
      update(state, fn -> compute_dec(state) end)
    end)
  end

  defp compute_inc(%{value: 9} = state) do
    send(state.counter, {:overflow, [state.key, :inc]})
    0
  end

  defp compute_inc(%{value: n}) do
    n + 1
  end

  defp compute_dec(%{value: 0} = state) do
    send(state.counter, {:overflow, [state.key, :dec]})
    9
  end

  defp compute_dec(%{value: n}) do
    n - 1
  end

  defp update(state, func) do
    value = func.()
    broadcast(state.key, value)
    %{state | value: value}
  end

  defp broadcast(key, value) do
    Phoenix.PubSub.broadcast(PubSub, "counter", {:update, %{key => value}})
  end
end
