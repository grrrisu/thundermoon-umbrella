defmodule Sim.GridTest do
  use ExUnit.Case, async: true

  alias Sim.Grid

  test "create a new grid" do
    grid = Grid.create(2, 3)
    assert %{0 => %{0 => nil, 1 => nil, 2 => nil}, 1 => %{0 => nil, 1 => nil, 2 => nil}} = grid
  end

  test "create a new grid with 0 as default" do
    grid = Grid.create(2, 3, 0)
    assert %{0 => %{0 => 0, 1 => 0, 2 => 0}, 1 => %{0 => 0, 1 => 0, 2 => 0}} = grid
  end

  test "create a new grid with a function" do
    grid = Grid.create(2, 3, fn x, y -> x + y end)
    assert 3 == Grid.get(grid, 1, 2)
  end

  test "create a new grid from a list" do
    list = [
      [0, 2, 3],
      [4, 5, 6],
      [7, 8, 9]
    ]

    grid = Grid.create(3, 3, list)
    assert 7 == Grid.get(grid, 0, 0)
    assert 3 == Grid.get(grid, 2, 2)
  end

  test "set and read from grid" do
    grid = Grid.create(2, 3)
    assert nil == Grid.get(grid, 1, 2)
    new_grid = Grid.put(grid, 1, 2, "value")
    assert "value" == Grid.get(new_grid, 1, 2)
  end

  test "read outside of grid" do
    grid = Grid.create(2, 3, "one")
    assert {:error, _msg} = Grid.get(grid, 3, 2)
  end

  test "put outside of grid" do
    grid = Grid.create(2, 3)
    assert {:error, _msg} = Grid.put(grid, 3, 2, "one")
  end

  test "read with invalid coordinates" do
    grid = Grid.create(2, 3, "one")
    assert {:error, _msg} = Grid.get(grid, "two", "one")
  end

  test "write with invalid coordinates" do
    grid = Grid.create(2, 3, "one")
    assert {:error, _msg} = Grid.put(grid, "two", "one", "foo")
  end

  test "map grid" do
    grid = Grid.create(2, 3, fn x, y -> x + y end)

    expected = [
      [0, 2, 2],
      [1, 2, 3],
      [0, 1, 1],
      [1, 1, 2],
      [0, 0, 0],
      [1, 0, 1]
    ]

    assert ^expected = Grid.map(grid, fn x, y, v -> [x, y, v] end)
  end

  test "merge field" do
    grid = Grid.create(1, 2, %{some_value: 3})
    grid = Grid.merge_field(grid, 0, 0, %{some_value: 0})
    grid = Grid.merge_field(grid, 0, 1, %{other_value: 5})
    assert %{some_value: 0} = Grid.get(grid, 0, 0)
    assert %{other_value: 5, some_value: 3} = Grid.get(grid, 0, 1)
  end
end
