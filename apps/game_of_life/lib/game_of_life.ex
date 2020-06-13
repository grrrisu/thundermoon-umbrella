defmodule GameOfLife do
  use Sim.Realm, name: __MODULE__

  @moduledoc """
  Context for game of life.
  It acts as a single point of entry to the game.
  """

  # game of life specific

  alias GameOfLife.{Grid, Simulation}

  def start_sim() do
    start_sim(fn data -> Simulation.sim(data) end)
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

  # def recreate() do
  #   :ok = GenServer.stop(Realm)
  # end

  # def clear() do
  #   stop()
  #   Logger.info("clear grid")
  #   get_root() |> GenServer.call(:clear)
  # end

  # def restart() do
  #   stop()
  #   GenServer.call(Realm, :restart_root)
  # end

  # def toggle(x, y) do
  #   case started?() do
  #     true ->
  #       {:error, "no write operations while simulating allowed"}

  #     false ->
  #       Logger.debug("toggle cell #{x}, #{y}")
  #       get_root() |> GenServer.call({:toggle, x, y})
  #   end
  # end
end
