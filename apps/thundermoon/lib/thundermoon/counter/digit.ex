defmodule Thundermoon.Digit do
  use Agent

  def start() do
    Agent.start(fn -> 0 end)
  end

  def start_link() do
    Agent.start_link(fn -> 0 end)
  end

  def inc(pid) do
    Agent.update(pid, fn n -> raise "tschüsss" end)
  end
end
