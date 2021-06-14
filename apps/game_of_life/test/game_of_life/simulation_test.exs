defmodule GameOfLife.SimulationTest do
  use ExUnit.Case, async: true

  alias Sim.Torus, as: Grid
  alias GameOfLife.Simulation

  # https://de.wikipedia.org/wiki/Conways_Spiel_des_Lebens#Die_Spielregeln
  # https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life#Rules

  test "Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction." do
    grid = [
      [false, false, false],
      [false, false, false],
      [true, true, true]
    ]

    grid = Grid.create(3, 3, grid)
    changes = Simulation.sim(grid)
    assert true == changes[{1, 1}]
  end

  test "Any live cell with fewer than two live neighbours dies, as if by underpopulation." do
    grid = [
      [false, false, false],
      [false, true, false],
      [false, false, true]
    ]

    grid = Grid.create(3, 3, grid)
    changes = Simulation.sim(grid)
    assert false == changes[{1, 1}]
  end

  test "Any live cell with two or three live neighbours lives on to the next generation." do
    grid = [
      [false, false, false],
      [true, true, false],
      [false, true, true]
    ]

    grid = Grid.create(3, 3, grid)
    changes = Simulation.sim(grid)
    assert is_nil(changes[{1, 1}])
  end

  test "Any live cell with more than three live neighbours dies, as if by overpopulation." do
    grid = [
      [false, false, true],
      [true, true, false],
      [false, true, true]
    ]

    grid = Grid.create(3, 3, grid)
    changes = Simulation.sim(grid)
    assert false == changes[{1, 1}]
  end
end
