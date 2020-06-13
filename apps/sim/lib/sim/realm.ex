defmodule Sim.Realm do
  @moduledoc """
  The context for realm
  """

  alias Sim.Realm.Server

  def get_root() do
    GenServer.call(Server, :get_root)
  end

  def set_root(root) do
    GenServer.call(Server, {:set_root, root})
  end

  def create(factory, config) when is_atom(factory) do
    GenServer.call(Server, {:create, factory, config})
  end

  def recreate(factory, config) when is_atom(factory) do
    GenServer.call(Server, :stop_sim)
    GenServer.call(Server, {:create, factory, config})
  end

  def restart() do
    :ok = Sim.Realm.Supervisor.restart_realm()
  end

  def start_sim(func) do
    GenServer.call(Server, {:start_sim, func})
  end

  def stop_sim() do
    GenServer.call(Server, :stop_sim)
  end

  def started?() do
    GenServer.call(Server, :started?)
  end

  def sim(func) do
    GenServer.cast(Server, {:sim, func})
  end

  # game of life specific

  def start_sim() do
    start_sim(fn data -> GameOfLife.Simulation.sim(data) end)
  end

  def create(size) do
    create(Grid, %{size: size})
  end

  def recreate(size) do
    recreate(Grid, %{size: size})
  end

  def clear() do
  end

  def toggle() do
  end
end
