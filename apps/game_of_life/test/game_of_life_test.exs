defmodule GameOfLifeTest do
  use ExUnit.Case

  alias Sim.Torus, as: Grid

  test "init" do
    GameOfLife.restart()
    assert nil == GameOfLife.get_root()
  end

  test "create" do
    grid = GameOfLife.create(3)
    assert 3 == Grid.height(grid)
    assert 3 == Grid.width(grid)
  end

  test "start_sim" do
    GameOfLife.create(3)
    assert :ok = GameOfLife.start_sim()
    assert :ok = GameOfLife.stop_sim()
  end

  test "clear" do
    GameOfLife.create(3)
    grid = GameOfLife.clear()

    assert grid
           |> Map.values()
           |> Enum.map(&Map.values(&1))
           |> List.flatten()
           |> Enum.all?(&(&1 == false))
  end

  test "toggle" do
    grid = GameOfLife.create(3)
    value = Grid.get(grid, 0, 0)
    new_grid = GameOfLife.toggle(0, 0)
    assert !value == Grid.get(new_grid, 0, 0)
  end
end
