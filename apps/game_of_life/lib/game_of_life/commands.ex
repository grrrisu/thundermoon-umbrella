defmodule GameOfLife.Commands do
  use Sim.Commands.Helpers, app_module: GameOfLife
  use Sim.Commands.GlobalLock

  alias GameOfLife.{Grid, Simulation}

  @impl true
  def handle_command(%{command: :start}) do
    start_simulation_loop(100)
  end

  @impl true
  def handle_command(%{command: :stop}) do
    stop_simulation_loop()
  end

  @impl true
  def handle_command(%{command: :sim}) do
    change_data(fn grid -> Simulation.sim(grid) end)
  end

  @impl true
  def handle_command(%{command: :create, config: size}) do
    Grid.create(%{size: size}) |> set_data()
  end

  @impl true
  def handle_command(%{command: :recreate}) do
    change_data(fn grid -> Grid.create(%{size: Grid.height(grid)}) end)
  end

  @impl true
  def handle_command(%{command: :reset}) do
    set_data(nil)
  end

  @impl true
  def handle_command(%{command: :toggle, x: x, y: y}) do
    change_data(fn grid -> Grid.toggle(grid, x, y) end)
  end

  @impl true
  def handle_command(%{command: :clear}) do
    change_data(fn grid -> Grid.clear(grid) end)
  end
end
