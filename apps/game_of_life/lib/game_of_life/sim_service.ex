defmodule GameOfLife.SimService do
  use Sim.Commands.DataHelpers, app_module: GameOfLife

  alias GameOfLife.Simulation

  @impl true
  def execute({:sim, :tick, []}) do
    grid = get_data()
    changes = grid |> Simulation.sim()
    set_data(fn -> Sim.Grid.apply_changes(grid, changes) end)
    [{:changed, changes: changes}]
  end
end
