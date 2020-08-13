defmodule LotkaVolterra do
  @moduledoc """
  Context for Lotka Volterra Simulation.
  It acts as a single point of entry to the simulation.
  """

  alias Sim.Laboratory
  alias LotkaVolterra.Vegetation

  def create(pub_sub) do
    Laboratory.create(fn -> %Vegetation{} end, pub_sub)
  end

  def object(id) do
    Laboratory.object(id)
  end

  def start(id) do
    Laboratory.start(id, fn vegetation -> Vegetation.sim(vegetation) end)
  end

  def stop(id) do
    Laboratory.stop(id)
  end

  def delete(id) do
    Laboratory.delete(id)
  end
end
