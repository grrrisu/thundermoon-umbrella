defmodule GameOfLife do
  use Sim.Realm, app_module: __MODULE__

  @moduledoc """
  Context for game of life.
  It acts as a single point of entry to the game.
  """

  def reset() do
    stop_sim()
    send_command({:realm, :reset})
  end

  def recreate() do
    stop_sim()
    send_command({:realm, :recreate})
  end

  def clear() do
    send_command({:realm, :clear})
  end

  def toggle(x, y) do
    send_command({:user, :toggle, x: x, y: y})
  end
end
