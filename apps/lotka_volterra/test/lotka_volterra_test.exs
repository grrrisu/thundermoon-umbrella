defmodule LotkaVolterraTest do
  use ExUnit.Case
  doctest LotkaVolterra

  describe "simulation" do
    test "with default values" do
      {id, vegetation} = LotkaVolterra.create(ThundermoonWeb.PubSub)
      LotkaVolterra.start(id)
      # this would take 1 sec to the first change
      send(Sim.Laboratory.get(id).pid, :tick)
      assert vegetation.size < LotkaVolterra.object(id).size
      LotkaVolterra.stop(id)
    end
  end
end
