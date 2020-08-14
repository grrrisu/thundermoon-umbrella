defmodule Thundermoon.LotkaVolterra.FormDataTest do
  use ExUnit.Case, async: true

  alias Ecto.Changeset

  alias Thundermoon.LotkaVolterra.FormData
  alias LotkaVolterra.Vegetation

  test "set default values" do
    changeset = FormData.changeset(%Vegetation{})
    assert 650 == Changeset.get_field(changeset, :size)
  end

  test "overwrite values" do
    valid_params = %{capacity: 5000, birth_rate: 0.5, death_rate: 0.1, size: 800}
    changeset = FormData.changeset(%Vegetation{size: 650}, valid_params)
    assert 800 == Changeset.get_field(changeset, :size)
  end

  test "prevent invalid values" do
    changeset = FormData.changeset(%Vegetation{size: 650}, %{size: -50})
    refute changeset.valid?()
    refute changeset.errors[:size] |> is_nil()
  end
end
