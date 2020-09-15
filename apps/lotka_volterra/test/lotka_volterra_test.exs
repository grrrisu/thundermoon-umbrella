defmodule LotkaVolterraTest do
  use ExUnit.Case
  doctest LotkaVolterra

  alias Sim.Laboratory
  alias LotkaVolterra.{Vegetation, Herbivore}

  describe "simulation" do
    test "with default values" do
      {id, {vegetation, herbivore}} =
        LotkaVolterra.create({%Vegetation{}, %Herbivore{}}, ThundermoonWeb.PubSub)

      LotkaVolterra.start(id)
      # this would take 1 sec to the first change
      send(Laboratory.get(id).pid, :tick)
      {simulated_vegetation, simulated_herbivore} = LotkaVolterra.object(id)
      assert vegetation.size < simulated_vegetation.size
      assert herbivore.size < simulated_herbivore.size
      LotkaVolterra.stop(id)
    end
  end
end
