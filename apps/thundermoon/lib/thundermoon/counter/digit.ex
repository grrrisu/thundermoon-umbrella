defmodule Thundermoon.Digit do
  # agent is temporary as it will be restarted by the counter
  use Agent, restart: :temporary

  def start(n \\ 0) do
    Agent.start(fn -> n end)
  end

  def start_link() do
    Agent.start_link(fn -> 0 end)
  end

  def get(pid) do
    Agent.get(pid, & &1)
  end

  def inc(pid) do
    Agent.update(pid, fn n ->
      n + 1
      # raise "tschüsss"
    end)
  end

  def dec(pid) do
    Agent.update(pid, fn n ->
      n - 1
      # raise "tschüsss"
    end)
  end
end
