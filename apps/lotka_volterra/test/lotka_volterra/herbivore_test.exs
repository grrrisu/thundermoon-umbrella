defmodule LotkaVolterra.HerbivoreTest do
  use ExUnit.Case, async: true

  alias LotkaVolterra.{Vegetation, Herbivore}
  alias LotkaVolterra.Sim.Animal

  test "no food should be consumed if no Animal are around" do
    {vegetation, _} = Animal.sim(%Vegetation{size: 6500}, nil)
    assert 6500 == vegetation.size
  end

  test "herbivore grow and consume food" do
    vegetation = %Vegetation{size: 6500, capacity: 1300}
    herbivore = %Herbivore{size: 20}

    {new_vegetation, new_herbivore} = Animal.sim(vegetation, herbivore)
    assert 6400 == new_vegetation.size
    assert 30.0 == Float.round(new_herbivore.size)
  end

  test "herbivore almost die as there is too less food" do
    vegetation = %Vegetation{size: 100, capacity: 1300}
    herbivore = %Herbivore{size: 20}

    {new_vegetation, new_herbivore} = Animal.sim(vegetation, herbivore)
    assert 95.0 == new_vegetation.size
    assert 15.0 == Float.round(new_herbivore.size)
  end
end
