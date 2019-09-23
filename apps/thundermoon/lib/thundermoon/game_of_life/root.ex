defmodule Thundermoon.GameOfLife.Root do
  alias Sim.Grid

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts[:size], opts)
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
