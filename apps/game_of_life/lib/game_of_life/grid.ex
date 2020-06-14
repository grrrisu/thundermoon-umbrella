defmodule GameOfLife.Grid do
  alias Sim.Torus, as: Grid

  def toggle(grid, x, y) do
    current = Grid.get(grid, x, y)
    Grid.put(grid, x, y, not current)
  end

  def clear(grid) do
    Grid.create(Grid.width(grid), Grid.height(grid), false)
  end

  def create(%{size: size}, ratio \\ 3) do
    Grid.create(size, size, fn _x, _y ->
      :rand.uniform(ratio) == 1
    end)
  end
end
