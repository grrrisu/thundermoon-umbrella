defmodule GameOfLife.UserService do
  use Sim.Commands.SimHelpers, app_module: GameOfLife
  use Sim.Commands.DataHelpers, app_module: GameOfLife

  alias GameOfLife.Grid

  @impl true
  def execute({:user, :start, delay: delay}) do
    start_simulation_loop(delay || 100)
  end

  @impl true
  def execute({:user, :stop, []}) do
    stop_simulation_loop()
  end

  @impl true
  def execute({:user, :create, config: size}) do
    Grid.create(%{size: size}) |> set_data()
  end

  @impl true
  def execute({:user, :recreate, []}) do
    change_data(fn grid -> Grid.create(%{size: Grid.height(grid)}) end)
  end

  @impl true
  def execute({:user, :reset, []}) do
    set_data(nil)
  end

  @impl true
  def execute({:user, :toggle, x: x, y: y}) do
    change_data(fn grid -> Grid.toggle(grid, x, y) end)
  end

  @impl true
  def execute({:user, :clear, []}) do
    change_data(fn grid -> Grid.clear(grid) end)
  end
end
