defmodule Thundermoon.GameOfLife.Grid do
  alias Sim.Grid

  def start_link(size) do
    GenServer.start_link(__MODULE__, size, name: __MODULE__)
  end

  def init(size) do
    {:ok, create(size)}
  end

  defp create(size) do
    Grid.create(size, size, fn _x, _y ->
      :rand.uniform(3) == 1
    end)
  end
end
