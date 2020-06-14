defmodule Sim.TorusTest do
  use ExUnit.Case, async: true

  alias Sim.Torus, as: Grid

  test "create a new grid" do
    grid = Grid.create(2, 3)
    assert %{0 => %{0 => nil, 1 => nil, 2 => nil}, 1 => %{0 => nil, 1 => nil, 2 => nil}} = grid
  end

  test "set and read from grid" do
    grid = Grid.create(2, 3, fn x, y -> {x, y} end)
    assert {1, 2} == Grid.get(grid, 1, 2)
    new_grid = Grid.put(grid, 1, 2, "value")
    assert "value" == Grid.get(new_grid, 1, 2)
  end

  test "read outside of grid x too big" do
    grid = Grid.create(2, 3, fn x, y -> {x, y} end)
    assert {1, 2} = Grid.get(grid, 3, 2)
  end

  test "read outside of grid x negative" do
    grid = Grid.create(2, 3, fn x, y -> {x, y} end)
    assert {1, 2} = Grid.get(grid, -3, 2)
  end

  test "read outside of grid y too big" do
    grid = Grid.create(2, 3, fn x, y -> {x, y} end)
    assert {1, 2} = Grid.get(grid, 1, 5)
  end

  test "read outside of grid y negative" do
    grid = Grid.create(2, 3, fn x, y -> {x, y} end)
    assert {1, 1} = Grid.get(grid, 1, -2)
  end

  test "put outside of grid x too big" do
    grid = Grid.create(2, 3, fn x, y -> {x, y} end)
    assert new_grid = Grid.put(grid, 3, 2, "value")
    assert "value" = Grid.get(new_grid, 1, 2)
  end

  test "put outside of grid x negative" do
    grid = Grid.create(2, 3, fn x, y -> {x, y} end)
    assert new_grid = Grid.put(grid, -3, 2, "value")
    assert "value" = Grid.get(new_grid, 1, 2)
  end

  test "put outside of grid y too big" do
    grid = Grid.create(2, 3, fn x, y -> {x, y} end)
    assert new_grid = Grid.put(grid, 1, 5, "value")
    assert "value" = Grid.get(new_grid, 1, 2)
  end

  test "put outside of grid y negative" do
    grid = Grid.create(2, 3, fn x, y -> {x, y} end)
    assert new_grid = Grid.put(grid, 1, -2, "value")
    assert "value" = Grid.get(new_grid, 1, 1)
  end

  test "read with invalid coordinates" do
    grid = Grid.create(2, 3, "one")
    assert {:error, _msg} = Grid.get(grid, "two", "one")
  end

  test "write with invalid coordinates" do
    grid = Grid.create(2, 3, "one")
    assert {:error, _msg} = Grid.put(grid, "two", "one", "foo")
  end
end
