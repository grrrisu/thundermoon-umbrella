defmodule LotkaVolterra do
  @moduledoc """
  Context for Lotka Volterra Simulation.
  It acts as a single point of entry to the simulation.
  """

  alias Sim.Laboratory
  alias LotkaVolterra.Sim.Vegetations
  alias LotkaVolterra.Sim.Animal
  alias LotkaVolterra.Vegetation

  def create(nil, pub_sub), do: create({%Vegetation{}, nil, nil}, pub_sub)

  def create({%Vegetation{} = vegetation, herbivore, predator}, pub_sub) do
    Laboratory.create(fn -> {vegetation, herbivore, predator} end, pub_sub)
  end

  def update(id, type, entity) do
    Laboratory.update(id, type, entity)
  end

  def update_object(id, update_func) do
    Laboratory.update_object(id, update_func)
  end

  def object(id) do
    Laboratory.object(id)
  end

  def start(id) do
    Laboratory.start(id, fn {vegetation, herbivore, predator} ->
      vegetation = Vegetations.sim(vegetation)
      {vegetation, herbivore} = Animal.sim(vegetation, herbivore)
      {herbivore, predator} = Animal.sim(herbivore, predator)
      {vegetation, herbivore, predator}
    end)
  end

  def stop(id) do
    Laboratory.stop(id)
  end

  def delete(id) do
    Laboratory.delete(id)
  end
end
