defmodule Sim.Torus do
  defdelegate create(width, height, value \\ nil), to: Sim.Grid
  defdelegate width(grid), to: Sim.Grid
  defdelegate height(grid), to: Sim.Grid

  def get(grid, x, y) when is_integer(x) and x >= map_size(grid) do
    get(grid, x - width(grid), y)
  end

  def get(grid, x, y) when is_integer(x) and x < 0 do
    get(grid, x + width(grid), y)
  end

  def get(%{0 => columns} = grid, x, y) when is_integer(y) and y >= map_size(columns) do
    get(grid, x, y - height(grid))
  end

  def get(grid, x, y) when is_integer(y) and y < 0 do
    get(grid, x, y + height(grid))
  end

  defdelegate get(grid, x, y), to: Sim.Grid

  def put(grid, x, y, value) when is_integer(x) and x >= map_size(grid) do
    put(grid, x - width(grid), y, value)
  end

  def put(grid, x, y, value) when is_integer(x) and x < 0 do
    put(grid, x + width(grid), y, value)
  end

  def put(%{0 => columns} = grid, x, y, value) when is_integer(y) and y >= map_size(columns) do
    put(grid, x, y - height(grid), value)
  end

  def put(grid, x, y, value) when is_integer(y) and y < 0 do
    put(grid, x, y + height(grid), value)
  end

  defdelegate put(grid, x, y, value), to: Sim.Grid
end
