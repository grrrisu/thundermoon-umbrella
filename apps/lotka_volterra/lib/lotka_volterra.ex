defmodule LotkaVolterra do
  use Sim.Realm, app_module: __MODULE__

  @moduledoc """
  Context for Lotka Volterra Simulation.
  It acts as a single point of entry to the simulation.
  """

  # alias GameOfLife.Grid

  # def create(size) do
  #   create(Grid, %{size: size})
  # end

  # def recreate() do
  #   stop_sim()
  #   call_server(:recreate)
  # end

  # def clear() do
  #   stop_sim()
  #   call_server(:clear)
  # end

  # def toggle(x, y) do
  #   call_server({:toggle, x, y})
  # end
end
