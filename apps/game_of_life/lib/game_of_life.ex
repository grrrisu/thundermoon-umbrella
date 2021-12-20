defmodule GameOfLife do
  use Sim.Realm, app_module: __MODULE__

  @moduledoc """
  Context for game of life.
  It acts as a single point of entry to the game.
  """

  def reset() do
    stop_sim()
    send_command({:user, :reset})
  end

  def recreate() do
    stop_sim()
    send_command({:user, :recreate})
  end

  def clear() do
    send_command({:user, :clear})
  end

  def start_sim() do
    send_command({:user, :start, delay: 100, command: {:sim, :tick}})
  end

  def toggle(x, y) do
    send_command({:user, :toggle, x: x, y: y})
  end
end
