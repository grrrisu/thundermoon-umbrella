defmodule Thundermoon.GameOfLife.GridTest do
  use ExUnit.Case, async: true

  alias Thundermoon.GameOfLife.Grid

  test "create a new grid" do
    assert {:ok, %{grid: grid}} = Grid.init(5)
    assert is_boolean(Sim.Grid.get(grid, 4, 4))
  end
end
