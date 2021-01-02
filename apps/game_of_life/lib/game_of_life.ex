defmodule GameOfLife do
  use Sim.Realm, app_module: __MODULE__

  @moduledoc """
  Context for game of life.
  It acts as a single point of entry to the game.
  """

  def recreate() do
    stop_sim()
    send_command(%{command: :recreate})
  end

  def clear() do
    send_command(%{command: :clear})
  end

  def toggle(x, y) do
    send_command(%{command: :toggle, x: x, y: y})
  end
end
