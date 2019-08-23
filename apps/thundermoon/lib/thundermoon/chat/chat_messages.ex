defmodule Thundermoon.ChatMessages do
  use Agent

  def start_link(_opts \\ []) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def add(message) do
    Agent.get_and_update(__MODULE__, fn list -> {message, [message | list]} end)
  end

  def list do
    Agent.get(__MODULE__, & &1)
  end

  def clear do
    Agent.get_and_update(__MODULE__, fn _list -> {[], []} end)
  end
end
