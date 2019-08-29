defmodule Thundermoon.Digit do
  # agent is temporary as it will be restarted by the counter
  use Agent, restart: :temporary

  def start(n \\ 0) do
    Agent.start(fn -> n end)
  end

  def start_link() do
    Agent.start_link(fn -> 0 end)
  end

  def inc(pid) do
    Agent.update(pid, fn _n -> raise "tschüsss" end)
  end
end
