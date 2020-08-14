defmodule LotkaVolterra.VegetationTest do
  use ExUnit.Case, async: true

  alias LotkaVolterra.Vegetation

  test "calculate delta of default vegetation" do
    vegetation = %Vegetation{size: 650, capacity: 1300}
    assert 32.5 == Vegetation.delta(vegetation)
  end

  test "calculate delta already reached max vegetation" do
    vegetation = %Vegetation{size: 1300, capacity: 1300}
    assert 0.0 == Vegetation.delta(vegetation)
  end

  test "calculate delta of zero vegetation" do
    vegetation = %Vegetation{size: 0}
    assert 0.0 == Vegetation.delta(vegetation)
  end
end
