defmodule GameOfLife.CommandHandler do
  use Sim.Commands.Helpers, app_module: GameOfLife
  use Sim.Commands.GlobalLock

  alias GameOfLife.{Grid, Simulation}

  @impl true
  def handle_command({:sim_start, delay: delay}) do
    start_simulation_loop(delay)
  end

  @impl true
  def handle_command({:sim_stop}) do
    stop_simulation_loop()
  end

  @impl true
  def handle_command({:sim}) do
    change_data(fn grid -> Simulation.sim(grid) end)
  end

  @impl true
  def handle_command({:create, config: size}) do
    Grid.create(%{size: size}) |> set_data()
  end

  @impl true
  def handle_command({:recreate}) do
    change_data(fn grid -> Grid.create(%{size: Grid.height(grid)}) end)
  end

  @impl true
  def handle_command({:reset}) do
    set_data(nil)
  end

  @impl true
  def handle_command({:toggle, x: x, y: y}) do
    change_data(fn grid -> Grid.toggle(grid, x, y) end)
  end

  @impl true
  def handle_command({:clear}) do
    change_data(fn grid -> Grid.clear(grid) end)
  end
end
