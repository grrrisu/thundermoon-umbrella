defmodule GameOfLifeTest do
  use ExUnit.Case, async: false

  alias Sim.Torus, as: Grid

  setup do
    Phoenix.PubSub.subscribe(ThundermoonWeb.PubSub, "GameOfLife")

    on_exit(fn ->
      Phoenix.PubSub.unsubscribe(ThundermoonWeb.PubSub, "GameOfLife")
    end)

    :ok
  end

  test "init" do
    GameOfLife.reset()
    assert_receive({:update, data: nil})
  end

  test "create" do
    :ok = GameOfLife.create(3)
    assert_receive({:update, data: _})
    assert grid = GameOfLife.get_root()
    assert is_map(grid)
    assert 3 == Grid.height(grid)
    assert 3 == Grid.width(grid)
    assert is_boolean(Grid.get(grid, 1, 1))
  end

  test "start_sim" do
    :ok = GameOfLife.create(3)
    assert :ok = GameOfLife.start_sim()
    assert_receive({:sim, started: true})
    assert :ok = GameOfLife.stop_sim()
    assert_receive({:sim, started: false})
  end

  test "clear" do
    :ok = GameOfLife.create(3)
    assert_receive({:update, data: _})
    GameOfLife.clear()
    assert_receive({:update, data: _})
    grid = GameOfLife.get_root()

    assert grid
           |> Map.values()
           |> Enum.map(&Map.values(&1))
           |> List.flatten()
           |> Enum.all?(&(&1 == false))
  end

  test "toggle" do
    :ok = GameOfLife.create(3)
    assert_receive({:update, data: _})
    grid = GameOfLife.get_root()
    value = Grid.get(grid, 0, 0)
    :ok = GameOfLife.toggle(0, 0)
    assert_receive({:update, data: _})
    new_grid = GameOfLife.get_root()
    assert !value == Grid.get(new_grid, 0, 0)
  end
end
