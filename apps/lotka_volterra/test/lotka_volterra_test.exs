defmodule LotkaVolterraTest do
  use ExUnit.Case
  doctest LotkaVolterra

  alias Sim.Laboratory
  alias LotkaVolterra.{Vegetation, Herbivore, Predator}

  describe "simulation" do
    test "with default values" do
      {id, {vegetation, herbivore, predator}} =
        LotkaVolterra.create({%Vegetation{}, %Herbivore{}, %Predator{}}, ThundermoonWeb.PubSub)

      LotkaVolterra.start(id)
      # this would take 1 sec to the first change
      send(Laboratory.get(id).pid, :tick)
      {simulated_vegetation, simulated_herbivore, simulated_predator} = LotkaVolterra.object(id)
      assert vegetation.size < simulated_vegetation.size
      assert herbivore.size < simulated_herbivore.size
      assert predator.size != simulated_predator.size
      LotkaVolterra.stop(id)
    end
  end
end
