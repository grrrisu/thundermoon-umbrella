defmodule Thundermoon.GameOfLife.Grid do
  use GenServer, restart: :temporary

  alias Sim.Grid
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

  defp create(size) do
    grid =
      Grid.create(size, size, fn _x, _y ->
        :rand.uniform(3) == 1
      end)

    Endpoint.broadcast("game_of_life", "update", %{grid: grid})
    grid
  end
end
