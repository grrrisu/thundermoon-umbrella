defmodule Sim.Grid do
  alias Sim.Grid

  def create(width, height, default \\ nil)

  def create(width, height, func) when is_function(func) do
    0..(width - 1)
    |> Map.new(fn x ->
      {x,
       0..(height - 1)
       |> Map.new(fn y ->
         {y, func.(x, y)}
       end)}
    end)
  end

  def create(width, height, value) do
    Grid.create(width, height, fn _x, _y -> value end)
  end

  def get(%{0 => columns} = grid, x, y)
      when x > 0 and x < map_size(grid) and y > 0 and y < map_size(columns) do
    get_in(grid, [x, y])
  end

  def get(grid, x, y) when is_integer(x) and is_integer(y) do
    {:error,
     "coordinates x: #{x}, y: #{y} outside of grid width: #{width(grid)}, height: #{height(grid)}"}
  end

  def get(_grid, x, y) do
    {:error, "only integers are allowed as coordinates, x: #{x}, y: #{y}"}
  end

  def put(%{0 => columns} = grid, x, y, value)
      when x > 0 and x < map_size(grid) and y > 0 and y < map_size(columns) do
    put_in(grid, [x, y], value)
  end

  def put(grid, x, y, _value) when is_integer(x) and is_integer(y) do
    {:error,
     "coordinates x: #{x}, y: #{y} outside of grid width: #{width(grid)}, height: #{height(grid)}"}
  end

  def put(_grid, x, y, _value) do
    {:error, "only integers are allowed as coordinates, x: #{x}, y: #{y}"}
  end

  def width(grid) do
    map_size(grid)
  end

  def height(grid) do
    map_size(grid[0])
  end
end
