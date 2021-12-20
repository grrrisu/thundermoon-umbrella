defmodule GameOfLife.SimService do
  use Sim.Commands.DataHelpers, app_module: GameOfLife

  @behaviour Sim.CommandHandler

  alias GameOfLife.Simulation

  @impl true
  def execute(:tick, []) do
    grid = get_data()
    changes = grid |> Simulation.sim()
    set_data(fn -> Sim.Grid.apply_changes(grid, changes) end)
    [{:changed, changes: changes}]
  end

  @impl true
  def execute(any, args) do
    raise "unknown sim command #{any} with args #{inspect(args)}"
  end
end
