defmodule Thundermoon.GameOfLife do
  @moduledoc """
  Context for game of life.
  It acts as a single point of entry to the game.
  """

  alias Thundermoon.GameOfLife.{Realm, Grid, SimulationLoop}

  def create(size) do
    GenServer.call(Realm, {:create, Grid, size})
  end

  def get_grid() do
    case get_root() do
      nil -> nil
      pid -> GenServer.call(pid, :get_grid)
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
    func = fn -> Thundermoon.GameOfLife.sim() end
    GenServer.cast(SimulationLoop, {:start, func})
  end

  def stop() do
    GenServer.cast(SimulationLoop, :stop)
  end

  def started?() do
    GenServer.call(SimulationLoop, :started?)
  end
end
