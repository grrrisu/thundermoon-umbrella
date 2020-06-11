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
    # :ok = Supervisor.restart_child(Sim.Realm.Supervisor, Sim.Realm.Data)
    # broadcast new data
  end

  def start_sim() do
    GenServer.call(Server, :start_sim)
  end

  def stop_sim() do
    GenServer.call(Server, :stop_sim)
  end

  def started?() do
    GenServer.call(Server, :started?)
  end

  def sim() do
    GenServer.call(Server, :sim)
  end

  # game of life specific

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
