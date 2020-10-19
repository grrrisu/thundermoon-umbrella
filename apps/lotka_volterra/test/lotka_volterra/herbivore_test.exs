defmodule LotkaVolterra.HerbivoreTest do
  use ExUnit.Case, async: true

  alias LotkaVolterra.{Vegetation, Herbivore}
  alias LotkaVolterra.Sim.Animal

  test "no food should be consumed if no Animal are around" do
    {vegetation, _} = Animal.sim(%Vegetation{size: 650}, nil)
    assert 650 == vegetation.size
  end

  test "herbivore grow and consume food" do
    vegetation = %Vegetation{size: 650, capacity: 1300}
    herbivore = %Herbivore{size: 20}

    {new_vegetation, new_herbivore} = Animal.sim(vegetation, herbivore)
    assert 645 == new_vegetation.size
    assert 29.0 == Float.round(new_herbivore.size)
  end

  test "herbivore almost die as there is too less food" do
    vegetation = %Vegetation{size: 10, capacity: 1300}
    herbivore = %Herbivore{size: 20}

    {new_vegetation, new_herbivore} = Animal.sim(vegetation, herbivore)
    assert 5.0 == new_vegetation.size
    assert 4.0 == Float.round(new_herbivore.size)
  end
end
