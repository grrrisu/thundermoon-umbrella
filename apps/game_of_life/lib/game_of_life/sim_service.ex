defmodule GameOfLife.SimService do
  use Sim.Commands.DataHelpers, app_module: GameOfLife

  @behaviour Sim.CommandHandler

  alias GameOfLife.Simulation
  alias Ximula.Grid

  @impl true
  def execute(:tick, []) do
    change_data(fn grid ->
      changes = grid |> Simulation.sim()
      grid = Grid.apply_changes(grid, changes)
      {grid, [{:changed, changes: changes}]}
    end)
  end

  @impl true
  def execute(any, args) do
    raise "unknown sim command #{any} with args #{inspect(args)}"
  end
end
