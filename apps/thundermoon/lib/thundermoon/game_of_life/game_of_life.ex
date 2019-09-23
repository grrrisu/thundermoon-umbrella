defmodule Thundermoon.GameOfLife do
  @moduledoc """
  Context for game of life.
  It acts as a single point of entry to the game.
  """

  alias Thundermoon.GameOfLife.Realm
  alias Thundermoon.GameOfLife.Grid

  def create(size) do
    GenServer.call(Realm, {:create, Grid, size})
  end

  def get_grid() do
    case get_root() do
      nil -> nil
      pid -> GenServer.call(pid, :get_grid)
    end
  end

  def get_root() do
    GenServer.call(Realm, :get_root)
  end
end
