defmodule Thundermoon.GameOfLife.Grid do
  use GenServer, restart: :temporary

  alias Sim.SeamlessGrid, as: Grid
  alias Thundermoon.GameOfLife.Simulation

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

  def handle_cast(:sim, state) do
    new_grid = Simulation.sim(state.grid)
    {:noreply, %{state | grid: new_grid}}
  end

  defp create(size) do
    grid =
      Grid.create(size, size, fn _x, _y ->
        :rand.uniform(3) == 1
      end)

    Endpoint.broadcast("Thundermoon.GameOfLife", "update", %{grid: grid})
    grid
  end
end
