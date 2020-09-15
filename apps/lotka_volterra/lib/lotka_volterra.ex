defmodule LotkaVolterra do
  @moduledoc """
  Context for Lotka Volterra Simulation.
  It acts as a single point of entry to the simulation.
  """

  alias Sim.Laboratory
  alias LotkaVolterra.Sim.Vegetations
  alias LotkaVolterra.Sim.Herbivores
  alias LotkaVolterra.Vegetation

  def create(nil, pub_sub), do: create({%Vegetation{}, nil}, pub_sub)

  def create({%Vegetation{} = vegetation, herbivore}, pub_sub) do
    Laboratory.create(fn -> {vegetation, herbivore} end, pub_sub)
  end

  def object(id) do
    Laboratory.object(id)
  end

  def start(id) do
    Laboratory.start(id, fn {vegetation, herbivore} ->
      Vegetations.sim(vegetation)
      |> Herbivores.sim(herbivore)
    end)
  end

  def stop(id) do
    Laboratory.stop(id)
  end

  def delete(id) do
    Laboratory.delete(id)
  end
end
