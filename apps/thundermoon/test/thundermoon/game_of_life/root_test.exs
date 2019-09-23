defmodule Thundermoon.GameOfLife.RootTest do
  use ExUnit.Case, async: true

  alias Sim.Grid
  alias Thundermoon.GameOfLife.Root

  test "create a new grid" do
    assert {:ok, grid} = Root.init(5)
    assert is_boolean(Grid.get(grid, 4, 4))
  end
end
