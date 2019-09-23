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
end
