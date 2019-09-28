defmodule Thundermoon.GameOfLife do
  @moduledoc """
  Context for game of life.
  It acts as a single point of entry to the game.
  """

  alias Thundermoon.GameOfLife.{Realm, Grid, SimulationLoop}
  alias Thundermoon.GameOfLife.Simulation

  def create(size) do
    GenServer.call(Realm, {:create, Grid, size})
  end

  def get_grid() do
    case get_root() do
      nil -> nil
      pid -> GenServer.call(pid, :get_grid)
    end
  end

  def set_grid(grid) do
    case get_root() do
      nil -> nil
      pid -> GenServer.call(pid, {:set_grid, grid})
    end
  end

  def recreate() do
    :ok = GenServer.stop(Realm)
  end

  def clear() do
    stop()
    get_root() |> GenServer.call(:clear)
  end

  def restart() do
    stop()
    GenServer.call(Realm, :restart_root)
  end

  def toggle(x, y) do
    case started?() do
      true -> {:error, "no write operations while simulating allowed"}
      # TODO
      false -> {x, y}
    end
  end

  def sim() do
    case get_root() do
      nil -> nil
      pid -> GenServer.cast(pid, :sim)
    end
  end

  def get_root() do
    GenServer.call(Realm, :get_root)
  end

  def start() do
    func = fn ->
      get_grid()
      |> Simulation.sim()
      |> set_grid()
    end

    GenServer.cast(SimulationLoop, {:start, func})
  end

  def stop() do
    GenServer.cast(SimulationLoop, :stop)
  end

  def started?() do
    GenServer.call(SimulationLoop, :started?)
  end
end
