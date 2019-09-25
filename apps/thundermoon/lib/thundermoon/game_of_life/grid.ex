defmodule Thundermoon.GameOfLife.Grid do
  use GenServer, restart: :temporary

  alias Sim.SeamlessGrid, as: Grid

  alias ThundermoonWeb.Endpoint

  def start_link(size) do
    GenServer.start_link(__MODULE__, size, name: __MODULE__)
  end

  def init(size) do
    {:ok, %{grid: create(size)}}
  end

  def handle_call(:get_grid, _from, state) do
    {:reply, state.grid, state}
  end

  def handle_call({:set_grid, grid}, _from, state) do
    broadcast(grid)
    {:reply, grid, %{state | grid: grid}}
  end

  defp create(size) do
    grid =
      Grid.create(size, size, fn _x, _y ->
        :rand.uniform(3) == 1
      end)

    broadcast(grid)
    grid
  end

  defp broadcast(grid) do
    Endpoint.broadcast("Thundermoon.GameOfLife", "update", %{grid: grid})
  end
end
