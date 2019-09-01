defmodule Thundermoon.Digit do
  # agent is temporary as it will be restarted by the counter
  use Agent, restart: :temporary

  alias ThundermoonWeb.Endpoint

  def start(key, value \\ 0) do
    Agent.start(fn ->
      broadcast(key, value)
      %{key: key, value: value}
    end)
  end

  def get(pid) do
    Agent.get(pid, & &1.value)
  end

  def inc(pid) do
    Agent.update(pid, fn state ->
      update(state, fn ->
        state.value + 1
      end)
    end)
  end

  def dec(pid) do
    Agent.update(pid, fn state ->
      update(state, fn ->
        state.value - 1
      end)
    end)
  end

  defp update(state, func) do
    value = func.()
    broadcast(state.key, value)
    %{state | value: value}
  end

  defp broadcast(key, value) do
    Endpoint.broadcast("counter", "update", %{key => value})
  end
end
