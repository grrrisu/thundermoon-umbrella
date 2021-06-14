defmodule GameOfLife.CommandHandler do
  use Sim.Commands.SimHelpers, app_module: GameOfLife
  use Sim.Commands.DataHelpers, app_module: GameOfLife

  alias GameOfLife.{Grid, Simulation}

  @impl true
  def execute({:sim, :start, delay: delay}) do
    start_simulation_loop(100)
  end

  @impl true
  def execute({:sim, :stop, []}) do
    stop_simulation_loop()
  end

  @impl true
  def execute({:sim, :tick, []}) do
    grid = get_data()
    changes = grid |> Simulation.sim()
    Sim.Grid.apply_changes(grid, changes) |> set_data()
    [{:changed, changes: changes}]
  end

  @impl true
  def execute({:realm, :create, config: size}) do
    Grid.create(%{size: size}) |> set_data()
  end

  @impl true
  def execute({:realm, :recreate, []}) do
    change_data(fn grid -> Grid.create(%{size: Grid.height(grid)}) end)
  end

  @impl true
  def execute({:realm, :reset, []}) do
    set_data(nil)
  end

  @impl true
  def execute({:user, :toggle, x: x, y: y}) do
    change_data(fn grid -> Grid.toggle(grid, x, y) end)
  end

  @impl true
  def execute({:realm, :clear, []}) do
    change_data(fn grid -> Grid.clear(grid) end)
  end
end
